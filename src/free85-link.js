// Free85 2.0 typed-object link protocol.
//
// This is the emulator cable for the clean-room Free85 packet format. The ROM
// exposes commands, selection, duplicate policy and progress through its link
// mailbox; this transport validates complete packets before atomically
// committing the receiving object store. Physical-cable validation remains a
// separate result and is never inferred from this loopback implementation.

const HEADER = 0x9d80;
const OBJECT_COUNT = HEADER + 4;
const HEAP_END = HEADER + 6;
const GENERATION = HEADER + 8;
const DIRECTORY = 0x9e00;
const ENTRY_COUNT = 64;
const ENTRY_SIZE = 16;
const HEAP_START = 0xa200;
const HEAP_LIMIT = 0xf800;
const FLAG_USED = 0x01;
const FLAG_EXTERNAL = 0x02;
const FLAG_SELECTED = 0x04;

export const FREE85_LINK_MAILBOX = Object.freeze({
  command: 0x9d70,
  status: 0x9d71,
  duplicate: 0x9d72,
  selected: 0x9d73,
  sequence: 0x9d74,
  error: 0x9d75,
  progress: 0x9d76,
  total: 0x9d78
});

export const FREE85_LINK_COMMAND = Object.freeze({
  idle: 0,
  send: 1,
  receive: 2,
  backup: 3,
  restore: 4,
  cancel: 5
});

export const FREE85_LINK_STATUS = Object.freeze({
  idle: 0,
  waiting: 1,
  active: 2,
  complete: 3,
  cancelled: 4,
  error: 5
});

export const FREE85_DUPLICATE_POLICY = Object.freeze({
  skip: 0,
  overwrite: 1,
  rename: 2
});

const MAGIC = Uint8Array.of(0x46, 0x38, 0x35, 0x4c); // F85L
const VERSION = 1;
const PACKET_HEADER_SIZE = 12;
const CHECKSUM_SIZE = 4;

export class Free85LinkError extends Error {
  constructor(code, message) {
    super(message);
    this.name = "Free85LinkError";
    this.code = code;
  }
}

function readBytes(machine, address, size) {
  return Uint8Array.from({ length: size }, (_, index) => machine.read8(address + index));
}

function writeBytes(machine, address, bytes) {
  for (let index = 0; index < bytes.length; index += 1) machine.write8(address + index, bytes[index]);
}

function write16(machine, address, value) {
  machine.write8(address, value);
  machine.write8(address + 1, value >>> 8);
}

function checksum(bytes) {
  let value = 0x811c9dc5;
  for (const byte of bytes) {
    value ^= byte;
    value = Math.imul(value, 0x01000193) >>> 0;
  }
  return value >>> 0;
}

function appendChecksum(body) {
  const packet = new Uint8Array(body.length + CHECKSUM_SIZE);
  packet.set(body);
  const value = checksum(body);
  packet[body.length] = value;
  packet[body.length + 1] = value >>> 8;
  packet[body.length + 2] = value >>> 16;
  packet[body.length + 3] = value >>> 24;
  return packet;
}

function packetChecksum(packet) {
  const offset = packet.length - CHECKSUM_SIZE;
  return (packet[offset] | (packet[offset + 1] << 8) | (packet[offset + 2] << 16) | (packet[offset + 3] << 24)) >>> 0;
}

function entryName(machine, entry) {
  const length = machine.read8(entry + 2);
  return String.fromCharCode(...readBytes(machine, entry + 3, length));
}

export function listFree85Objects(machine) {
  const objects = [];
  for (let index = 0; index < ENTRY_COUNT; index += 1) {
    const entry = DIRECTORY + index * ENTRY_SIZE;
    const flags = machine.read8(entry + 1);
    if ((flags & FLAG_USED) === 0) continue;
    const address = machine.read16(entry + 11);
    const size = machine.read16(entry + 13);
    objects.push({
      entry,
      type: machine.read8(entry),
      flags,
      name: entryName(machine, entry),
      address,
      size,
      payload: readBytes(machine, address, size)
    });
  }
  return objects;
}

export function selectFree85Objects(machine, predicate) {
  let selected = 0;
  for (const object of listFree85Objects(machine)) {
    const enabled = Boolean(predicate(object));
    machine.write8(object.entry + 1, enabled ? object.flags | FLAG_SELECTED : object.flags & ~FLAG_SELECTED);
    if (enabled) selected += 1;
  }
  machine.write8(FREE85_LINK_MAILBOX.selected, selected);
  return selected;
}

export function encodeFree85Packet(object, sequence = 0) {
  const name = Uint8Array.from(object.name, (character) => character.charCodeAt(0));
  if (name.length < 1 || name.length > 8) throw new Free85LinkError(1, "invalid object name");
  if (object.type < 1 || object.type > 11) throw new Free85LinkError(1, "invalid object type");
  if (object.payload.length < 1 || object.payload.length > HEAP_LIMIT - HEAP_START) {
    throw new Free85LinkError(1, "invalid object size");
  }
  const body = new Uint8Array(PACKET_HEADER_SIZE + name.length + object.payload.length);
  body.set(MAGIC, 0);
  body[4] = VERSION;
  body[5] = sequence;
  body[6] = sequence >>> 8;
  body[7] = object.type;
  body[8] = name.length;
  body[9] = object.payload.length;
  body[10] = object.payload.length >>> 8;
  body[11] = object.flags & FLAG_EXTERNAL ? FLAG_EXTERNAL : 0;
  body.set(name, PACKET_HEADER_SIZE);
  body.set(object.payload, PACKET_HEADER_SIZE + name.length);
  return appendChecksum(body);
}

export function decodeFree85Packet(packet) {
  const bytes = Uint8Array.from(packet);
  if (bytes.length < PACKET_HEADER_SIZE + 1 + CHECKSUM_SIZE) throw new Free85LinkError(2, "truncated packet");
  if (!MAGIC.every((byte, index) => bytes[index] === byte) || bytes[4] !== VERSION) {
    throw new Free85LinkError(3, "unsupported packet header");
  }
  const nameLength = bytes[8];
  const size = bytes[9] | (bytes[10] << 8);
  const expected = PACKET_HEADER_SIZE + nameLength + size + CHECKSUM_SIZE;
  if (nameLength < 1 || nameLength > 8 || size < 1 || bytes.length !== expected) {
    throw new Free85LinkError(2, "invalid packet length");
  }
  const body = bytes.subarray(0, bytes.length - CHECKSUM_SIZE);
  if (checksum(body) !== packetChecksum(bytes)) throw new Free85LinkError(4, "packet checksum mismatch");
  const nameBytes = bytes.subarray(PACKET_HEADER_SIZE, PACKET_HEADER_SIZE + nameLength);
  const name = String.fromCharCode(...nameBytes);
  if (!/^[A-Z][A-Z0-9]{0,7}$/.test(name)) throw new Free85LinkError(1, "invalid object name");
  const type = bytes[7];
  if (type < 1 || type > 11) throw new Free85LinkError(1, "invalid object type");
  return {
    sequence: bytes[5] | (bytes[6] << 8),
    type,
    name,
    external: Boolean(bytes[11] & FLAG_EXTERNAL),
    payload: Uint8Array.from(bytes.subarray(PACKET_HEADER_SIZE + nameLength, bytes.length - CHECKSUM_SIZE))
  };
}

function renamed(name, objects, type) {
  for (let suffix = 0; suffix < 26; suffix += 1) {
    const text = String.fromCharCode(65 + suffix);
    const candidate = `${name.slice(0, 8 - text.length)}${text}`;
    if (!objects.some((object) => object.type === type && object.name === candidate)) return candidate;
  }
  throw new Free85LinkError(6, "no duplicate rename is available");
}

function cloneObject(object) {
  return { ...object, payload: Uint8Array.from(object.payload) };
}

function planReceive(machine, decoded, { duplicate, replaceDynamic = false }) {
  let objects = listFree85Objects(machine).map(cloneObject);
  if (replaceDynamic) objects = objects.filter((object) => object.flags & FLAG_EXTERNAL);
  for (const incoming of decoded) {
    const match = objects.findIndex((object) => object.type === incoming.type && object.name === incoming.name);
    if (match >= 0) {
      if (duplicate === FREE85_DUPLICATE_POLICY.skip) continue;
      if (duplicate === FREE85_DUPLICATE_POLICY.rename) {
        objects.push({
          type: incoming.type,
          flags: FLAG_USED,
          name: renamed(incoming.name, objects, incoming.type),
          payload: Uint8Array.from(incoming.payload)
        });
        continue;
      }
      objects[match] = {
        ...objects[match],
        flags: objects[match].flags & (FLAG_USED | FLAG_EXTERNAL),
        payload: Uint8Array.from(incoming.payload)
      };
      continue;
    }
    objects.push({ type: incoming.type, flags: FLAG_USED, name: incoming.name, payload: Uint8Array.from(incoming.payload) });
  }

  if (objects.length > ENTRY_COUNT) throw new Free85LinkError(5, "object directory full");
  const internalSize = objects
    .filter((object) => !(object.flags & FLAG_EXTERNAL))
    .reduce((total, object) => total + object.payload.length, 0);
  if (internalSize > HEAP_LIMIT - HEAP_START) throw new Free85LinkError(5, "object heap full");
  for (const object of objects) {
    if ((object.flags & FLAG_EXTERNAL) && object.payload.length !== object.size) {
      throw new Free85LinkError(5, "external object size mismatch");
    }
  }
  return objects;
}

function commitObjects(machine, objects) {
  const generation = (machine.read8(GENERATION) + 1) & 0xff;
  for (let address = DIRECTORY; address < DIRECTORY + ENTRY_COUNT * ENTRY_SIZE; address += 1) machine.write8(address, 0);
  for (let address = HEAP_START; address < machine.read16(HEAP_END); address += 1) machine.write8(address, 0);
  let heap = HEAP_START;
  objects.forEach((object, index) => {
    const entry = DIRECTORY + index * ENTRY_SIZE;
    const name = Uint8Array.from(object.name, (character) => character.charCodeAt(0));
    const external = Boolean(object.flags & FLAG_EXTERNAL);
    const address = external ? object.address : heap;
    const size = object.payload.length;
    machine.write8(entry, object.type);
    machine.write8(entry + 1, FLAG_USED | (external ? FLAG_EXTERNAL : 0));
    machine.write8(entry + 2, name.length);
    writeBytes(machine, entry + 3, name);
    write16(machine, entry + 11, address);
    write16(machine, entry + 13, size);
    machine.write8(entry + 15, object.type ^ name.length ^ (size & 0xff) ^ (size >>> 8));
    writeBytes(machine, address, object.payload);
    if (!external) heap += size;
  });
  machine.write8(OBJECT_COUNT, objects.length);
  write16(machine, HEAP_END, heap);
  machine.write8(GENERATION, generation || 1);
}

function setMailbox(machine, { command, status, error = 0, progress = 0, total = 0 }) {
  if (command !== undefined) machine.write8(FREE85_LINK_MAILBOX.command, command);
  if (status !== undefined) machine.write8(FREE85_LINK_MAILBOX.status, status);
  machine.write8(FREE85_LINK_MAILBOX.error, error);
  write16(machine, FREE85_LINK_MAILBOX.progress, progress);
  write16(machine, FREE85_LINK_MAILBOX.total, total);
}

function normalizeFaultPackets(packets, fault = {}) {
  const transmitted = packets.map((packet) => Uint8Array.from(packet));
  if (fault.corruptPacketIndex !== undefined) {
    const packet = transmitted[fault.corruptPacketIndex];
    if (packet) packet[Math.max(PACKET_HEADER_SIZE, packet.length - CHECKSUM_SIZE - 1)] ^= 0x01;
  }
  return transmitted;
}

export class Free85LinkSession {
  constructor(left, right) {
    this.left = left;
    this.right = right;
  }

  packets(machine, { selectedOnly = false } = {}) {
    const sequence = machine.read8(FREE85_LINK_MAILBOX.sequence);
    const objects = listFree85Objects(machine).filter((object) => !selectedOnly || (object.flags & FLAG_SELECTED));
    if (selectedOnly && objects.length === 0) throw new Free85LinkError(7, "no objects selected");
    return objects.map((object, index) => encodeFree85Packet(object, sequence + index));
  }

  createBackup(machine) {
    const packets = this.packets(machine);
    const body = Uint8Array.from(packets.flatMap((packet) => Array.from(packet)));
    return Object.freeze({ version: VERSION, packets, checksum: checksum(body) });
  }

  restore(machine, backup, options = {}) {
    if (!backup || backup.version !== VERSION || !Array.isArray(backup.packets)) throw new Free85LinkError(3, "invalid backup");
    const body = Uint8Array.from(backup.packets.flatMap((packet) => Array.from(packet)));
    if (checksum(body) !== backup.checksum) throw new Free85LinkError(4, "backup checksum mismatch");
    return this.receive(machine, backup.packets, { ...options, replaceDynamic: true });
  }

  receive(machine, packets, { duplicate = FREE85_DUPLICATE_POLICY.overwrite, replaceDynamic = false, fault = {} } = {}) {
    const total = packets.reduce((sum, packet) => sum + packet.length, 0);
    setMailbox(machine, { status: FREE85_LINK_STATUS.active, total });
    try {
      if (fault.cancelled || fault.interruptAfterBytes !== undefined && fault.interruptAfterBytes < total) {
        throw new Free85LinkError(8, "transfer interrupted");
      }
      const transmitted = normalizeFaultPackets(packets, fault);
      const decoded = transmitted.map(decodeFree85Packet);
      if (fault.capacityLimit !== undefined) {
        const incomingBytes = decoded.reduce((sum, object) => sum + object.payload.length, 0);
        if (incomingBytes > fault.capacityLimit) throw new Free85LinkError(5, "fault-injected capacity limit");
      }
      const plan = planReceive(machine, decoded, { duplicate, replaceDynamic });
      commitObjects(machine, plan);
      setMailbox(machine, { command: FREE85_LINK_COMMAND.idle, status: FREE85_LINK_STATUS.complete, progress: total, total });
      return { received: decoded.length, bytes: total, objects: listFree85Objects(machine) };
    } catch (error) {
      const interrupted = error instanceof Free85LinkError && error.code === 8;
      setMailbox(machine, {
        command: FREE85_LINK_COMMAND.idle,
        status: interrupted ? FREE85_LINK_STATUS.cancelled : FREE85_LINK_STATUS.error,
        error: error instanceof Free85LinkError ? error.code : 0xff,
        total
      });
      throw error;
    }
  }

  send(sender, receiver, { duplicate = FREE85_DUPLICATE_POLICY.overwrite, fault } = {}) {
    const packets = this.packets(sender, { selectedOnly: true });
    setMailbox(sender, { status: FREE85_LINK_STATUS.active, total: packets.reduce((sum, packet) => sum + packet.length, 0) });
    try {
      const result = this.receive(receiver, packets, { duplicate, fault });
      setMailbox(sender, { command: FREE85_LINK_COMMAND.idle, status: FREE85_LINK_STATUS.complete, progress: result.bytes, total: result.bytes });
      return result;
    } catch (error) {
      setMailbox(sender, {
        command: FREE85_LINK_COMMAND.idle,
        status: error.code === 8 ? FREE85_LINK_STATUS.cancelled : FREE85_LINK_STATUS.error,
        error: error.code ?? 0xff
      });
      throw error;
    }
  }

  backup(sender, receiver, { fault } = {}) {
    const backup = this.createBackup(sender);
    const result = this.restore(receiver, backup, { duplicate: FREE85_DUPLICATE_POLICY.overwrite, fault });
    return { ...result, backup };
  }

  service({ fault } = {}) {
    const pairs = [[this.left, this.right], [this.right, this.left]];
    for (const [sender, receiver] of pairs) {
      const command = sender.read8(FREE85_LINK_MAILBOX.command);
      const receiverCommand = receiver.read8(FREE85_LINK_MAILBOX.command);
      const duplicate = receiver.read8(FREE85_LINK_MAILBOX.duplicate);
      if (command === FREE85_LINK_COMMAND.send && receiverCommand === FREE85_LINK_COMMAND.receive) {
        return this.send(sender, receiver, { duplicate, fault });
      }
      if (command === FREE85_LINK_COMMAND.backup && receiverCommand === FREE85_LINK_COMMAND.restore) {
        return this.backup(sender, receiver, { fault });
      }
      if (command === FREE85_LINK_COMMAND.cancel || receiverCommand === FREE85_LINK_COMMAND.cancel) {
        setMailbox(sender, { command: FREE85_LINK_COMMAND.idle, status: FREE85_LINK_STATUS.cancelled });
        setMailbox(receiver, { command: FREE85_LINK_COMMAND.idle, status: FREE85_LINK_STATUS.cancelled });
        throw new Free85LinkError(8, "transfer cancelled");
      }
    }
    return null;
  }
}
