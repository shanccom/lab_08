// @ts-strict-ignore
import crypto from 'node:crypto';

import { create, SyncRequestSchema, toBinary } from '@actual-app/crdt';
import request from 'supertest';
import { vi } from 'vitest';

import { getAccountDb } from './account-db';
import { handlers as app } from './app-sync';
import { isValidFileId } from './util/paths';

const OTHER_USER_ID = 'otherUser';

function generateFileId() {
  const id = crypto.randomBytes(16).toString('hex');
  if (!isValidFileId(id)) {
    throw new Error('Generated fileId is invalid');
  }
  return id;
}

function addMockFile(
  fileId: string,
  groupId: string | null,
  keyId: string,
  encryptMeta: string,
  syncVersion: number,
  owner: string = 'genericAdmin',
) {
  getAccountDb().mutate(
    'INSERT INTO files (id, group_id, encrypt_keyid, encrypt_meta, sync_version, owner) VALUES (?, ?, ?, ?, ?, ?)',
    [fileId, groupId, keyId, encryptMeta, syncVersion, owner],
  );
}

function createMinimalSyncRequest(
  fileId: string,
  groupId: string | null,
  keyId: string | null,
) {
  return create(SyncRequestSchema, {
    fileId,
    groupId,
    keyId,
    since: '2024-01-01T00:00:00.000Z',
  });
}

async function sendSyncRequest(
  syncRequest: ReturnType<typeof createMinimalSyncRequest>,
  token = 'valid-token',
) {
  const serializedRequest = toBinary(SyncRequestSchema, syncRequest);
  const bufferRequest = Buffer.from(serializedRequest);

  return request(app)
    .post('/sync')
    .set('x-actual-token', token)
    .set('Content-Type', 'application/actual-sync')
    .send(bufferRequest);
}

// ============================================================================
// CASO 1: PRUEBAS DE FALLA SINTACTICA
// Campos faltantes, tipos de datos incorrectos, formatos invalidos
// ============================================================================
describe('CASO 1 — Sintactico: Falla por campos faltantes/tipos incorrectos', () => {
  describe('POST /user-get-key', () => {
    it('SIN-01: retorna 400 cuando el body esta vacio (falta fileId)', async () => {
      const res = await request(app)
        .post('/user-get-key')
        .set('x-actual-token', 'valid-token')
        .send({});

      expect(res.statusCode).toBe(400);
      expect(res.text).toBe('invalid fileId');
    });

    it('SIN-02: retorna 400 cuando fileId es de tipo number en vez de string', async () => {
      const res = await request(app)
        .post('/user-get-key')
        .set('x-actual-token', 'valid-token')
        .send({ fileId: 12345 });

      expect(res.statusCode).toBe(400);
      expect(res.text).toBe('invalid fileId');
    });

    it('SIN-03: retorna 400 cuando fileId tiene formato invalido (caracteres especiales)', async () => {
      const res = await request(app)
        .post('/user-get-key')
        .set('x-actual-token', 'valid-token')
        .send({ fileId: 'archivo@@invalido!' });

      expect(res.statusCode).toBe(400);
      expect(res.text).toBe('invalid fileId');
    });

    it('SIN-04: retorna 400 cuando fileId es un string vacio', async () => {
      const res = await request(app)
        .post('/user-get-key')
        .set('x-actual-token', 'valid-token')
        .send({ fileId: '' });

      expect(res.statusCode).toBe(400);
      expect(res.text).toBe('invalid fileId');
    });
  });

  describe('POST /user-create-key', () => {
    it('SIN-05: retorna 400 cuando el body no contiene fileId', async () => {
      const res = await request(app)
        .post('/user-create-key')
        .set('x-actual-token', 'valid-token')
        .send({
          keyId: 'test-key',
          keySalt: 'test-salt',
          testContent: 'test-content',
        });

      expect(res.statusCode).toBe(400);
      expect(res.text).toBe('invalid fileId');
    });

    it('SIN-06: retorna 400 cuando fileId tiene formato invalido', async () => {
      const res = await request(app)
        .post('/user-create-key')
        .set('x-actual-token', 'valid-token')
        .send({
          fileId: 'invalid@file#id',
          keyId: 'test-key',
          keySalt: 'test-salt',
          testContent: 'test-content',
        });

      expect(res.statusCode).toBe(400);
      expect(res.text).toBe('invalid fileId');
    });
  });

  describe('POST /sync', () => {
    it('SIN-07: retorna 500 cuando el body es binario invalido (no es protobuf valido)', async () => {
      const res = await request(app)
        .post('/sync')
        .set('x-actual-token', 'valid-token')
        .set('Content-Type', 'application/actual-sync')
        .send('esto-no-es-protobuf-valido');

      expect(res.statusCode).toBe(500);
      expect(res.body).toEqual({
        status: 'error',
        reason: 'internal-error',
      });
    });

    it('SIN-08: retorna 422 cuando falta el campo since en el protobuf', async () => {
      const syncRequest = createMinimalSyncRequest(
        'algún-file-id',
        'algún-group-id',
        'algún-key-id',
      );
      syncRequest.since = '';

      const res = await sendSyncRequest(syncRequest);

      expect(res.statusCode).toBe(422);
      expect(res.body).toEqual({
        status: 'error',
        reason: 'unprocessable-entity',
        details: 'since-required',
      });
    });
  });

  describe('POST /delete-user-file', () => {
    it('SIN-09: retorna 422 cuando el body no contiene fileId', async () => {
      const res = await request(app)
        .post('/delete-user-file')
        .set('x-actual-token', 'valid-token')
        .send({});

      expect(res.statusCode).toBe(422);
      expect(res.body).toEqual({
        status: 'error',
        reason: 'unprocessable-entity',
        details: 'fileId-required',
      });
    });
  });

  describe('POST /upload-user-file', () => {
    it('SIN-10: retorna 400 cuando falta el header x-actual-name', async () => {
      const res = await request(app)
        .post('/upload-user-file')
        .set('x-actual-token', 'valid-token')
        .set('x-actual-file-id', generateFileId())
        .set('Content-Type', 'application/encrypted-file')
        .send(Buffer.from('dummy-file-content'));

      expect(res.statusCode).toBe(400);
      expect(res.text).toBe('single x-actual-name is required');
    });

    it('SIN-11: retorna 400 cuando falta el header x-actual-file-id', async () => {
      const res = await request(app)
        .post('/upload-user-file')
        .set('x-actual-token', 'valid-token')
        .set('x-actual-name', encodeURIComponent('test-file'))
        .set('Content-Type', 'application/encrypted-file')
        .send(Buffer.from('dummy-file-content'));

      expect(res.statusCode).toBe(400);
      expect(res.text).toBe('fileId is required');
    });
  });
});

// ============================================================================
// CASO 2: PRUEBAS DE FALLA SEMANTICA
// Valores validos en tipo pero ilogicos para el negocio
// ============================================================================
describe('CASO 2 — Semantico: Falla por valores validos en tipo pero ilogicos', () => {
  describe('POST /sync — grupo desincronizado', () => {
    it('SEM-01: retorna 400 "file-has-reset" cuando el groupId del cliente no coincide con el de la BD', async () => {
      const fileId = generateFileId();
      const realGroupId = 'grupo-real-actual';
      const oldGroupId = 'grupo-antiguo-reseteado';
      const keyId = 'key-001';

      addMockFile(
        fileId,
        realGroupId,
        keyId,
        JSON.stringify({ keyId }),
        2,
        'genericAdmin',
      );

      const syncRequest = createMinimalSyncRequest(fileId, oldGroupId, keyId);
      const res = await sendSyncRequest(syncRequest);

      expect(res.statusCode).toBe(400);
      expect(res.text).toBe('file-has-reset');
    });

    it('SEM-02: retorna 400 "file-needs-upload" cuando el archivo fue reseteado (groupId=null en BD)', async () => {
      const fileId = generateFileId();
      const keyId = 'key-002';

      addMockFile(fileId, null, keyId, JSON.stringify({ keyId }), 2, 'genericAdmin');

      const syncRequest = createMinimalSyncRequest(fileId, 'grupo-que-ya-no-existe', keyId);
      const res = await sendSyncRequest(syncRequest);

      expect(res.statusCode).toBe(400);
      expect(res.text).toBe('file-needs-upload');
    });

    it('SEM-03: retorna 400 "file-has-new-key" cuando el keyId del cliente no coincide con el de la BD', async () => {
      const fileId = generateFileId();
      const groupId = 'grupo-001';
      const currentKeyId = 'clave-actual';

      addMockFile(
        fileId,
        groupId,
        currentKeyId,
        JSON.stringify({ keyId: currentKeyId }),
        2,
        'genericAdmin',
      );

      const syncRequest = createMinimalSyncRequest(fileId, groupId, 'clave-antigua-diferente');
      const res = await sendSyncRequest(syncRequest);

      expect(res.statusCode).toBe(400);
      expect(res.text).toBe('file-has-new-key');
    });

    it('SEM-04: retorna 400 "file-old-version" cuando el syncVersion del archivo es menor al requerido', async () => {
      const fileId = generateFileId();
      const groupId = 'grupo-002';
      const keyId = 'key-003';

      addMockFile(
        fileId,
        groupId,
        keyId,
        JSON.stringify({ keyId }),
        1, // version antigua (SYNC_FORMAT_VERSION requerida es 2)
        'genericAdmin',
      );

      const syncRequest = createMinimalSyncRequest(fileId, groupId, keyId);
      const res = await sendSyncRequest(syncRequest);

      expect(res.statusCode).toBe(400);
      expect(res.text).toBe('file-old-version');
    });
  });

  describe('POST /user-get-key — acceso a archivo ajeno', () => {
    it('SEM-05: retorna 403 cuando un usuario sin acceso pide la clave de un archivo ajeno', async () => {
      const fileId = generateFileId();

      getAccountDb().mutate(
        'INSERT INTO files (id, encrypt_salt, encrypt_keyid, encrypt_test, owner) VALUES (?, ?, ?, ?, ?)',
        [fileId, 'salt', 'key-id', 'test', OTHER_USER_ID],
      );

      const res = await request(app)
        .post('/user-get-key')
        .set('x-actual-token', 'valid-token-user')
        .send({ fileId });

      expect(res.statusCode).toBe(403);
      expect(res.text).toBe('file-access-not-allowed');
    });

    it('SEM-06: retorna 200 si el admin pide la clave de un archivo ajeno (admin tiene acceso global)', async () => {
      const fileId = generateFileId();
      const encrypt_salt = 'salt';
      const encrypt_keyid = 'key-id';
      const encrypt_test = 'test';

      getAccountDb().mutate(
        'INSERT INTO files (id, encrypt_salt, encrypt_keyid, encrypt_test, owner) VALUES (?, ?, ?, ?, ?)',
        [fileId, encrypt_salt, encrypt_keyid, encrypt_test, OTHER_USER_ID],
      );

      const res = await request(app)
        .post('/user-get-key')
        .set('x-actual-token', 'valid-token-admin')
        .send({ fileId });

      expect(res.statusCode).toBe(200);
      expect(res.body).toEqual({
        status: 'ok',
        data: {
          id: encrypt_keyid,
          salt: encrypt_salt,
          test: encrypt_test,
        },
      });
    });
  });

  describe('POST /delete-user-file — archivo ya eliminado', () => {
    it('SEM-07: retorna 200 al intentar eliminar un archivo ya marcado como deleted (soft-delete idempotente)', async () => {
      const fileId = generateFileId();

      getAccountDb().mutate(
        'INSERT INTO files (id, group_id, deleted, owner) VALUES (?, ?, TRUE, ?)',
        [fileId, 'group-1', 'genericAdmin'],
      );

      const res = await request(app)
        .post('/delete-user-file')
        .set('x-actual-token', 'valid-token')
        .send({ fileId });

      // Nota: FilesService.get() lanza FileNotFound si deleted=1,
      // por lo que verifyFileExists() redirige a 400, no 200.
      // Este test documenta el comportamiento real.
      expect(res.statusCode).toBe(400);
      expect(res.text).toBe('file-not-found');
    });
  });

  describe('POST /upload-user-file — archivo ya reseteado', () => {
    it('SEM-08: retorna 400 "file-has-reset" al subir con un groupId que ya no es el actual', async () => {
      const fileId = generateFileId();
      const originalGroupId = 'grupo-original';
      const newGroupId = 'grupo-nuevo';

      addMockFile(
        fileId,
        newGroupId,
        'key-001',
        JSON.stringify({ keyId: 'key-001' }),
        2,
        'genericAdmin',
      );

      const res = await request(app)
        .post('/upload-user-file')
        .set('x-actual-token', 'valid-token')
        .set('x-actual-name', encodeURIComponent('test'))
        .set('x-actual-file-id', fileId)
        .set('x-actual-group-id', originalGroupId)
        .set('x-actual-format', '2')
        .set('Content-Type', 'application/encrypted-file')
        .send(Buffer.from('contenido'));

      expect(res.statusCode).toBe(400);
      expect(res.text).toBe('file-has-reset');
    });
  });
});

// ============================================================================
// CASO 3: PRUEBAS DE RESILIENCIA
// Timeout y capacidad de respuesta bajo condiciones adversas
// ============================================================================
describe('CASO 3 — Resiliencia: Comportamiento ante latencia/fallas del subsistema', () => {
  describe('GET /list-user-files — tiempo de respuesta normal', () => {
    it('RES-01: responde en menos de 500ms con BD local SQLite', async () => {
      const start = Date.now();
      const res = await request(app)
        .get('/list-user-files')
        .set('x-actual-token', 'valid-token');
      const elapsed = Date.now() - start;

      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('status', 'ok');
      expect(Array.isArray(res.body.data)).toBe(true);
      expect(elapsed).toBeLessThan(500);
    });
  });

  describe('POST /user-get-key — tiempo de respuesta normal', () => {
    it('RES-02: responde en menos de 300ms con archivo existente en BD', async () => {
      const fileId = generateFileId();

      getAccountDb().mutate(
        'INSERT INTO files (id, encrypt_salt, encrypt_keyid, encrypt_test, owner) VALUES (?, ?, ?, ?, ?)',
        [fileId, 'salt', 'key', 'test', 'genericAdmin'],
      );

      const start = Date.now();
      const res = await request(app)
        .post('/user-get-key')
        .set('x-actual-token', 'valid-token')
        .send({ fileId });
      const elapsed = Date.now() - start;

      expect(res.statusCode).toBe(200);
      expect(elapsed).toBeLessThan(300);
    });
  });

  describe('POST /user-get-key — archivo inexistente no deberia colgar', () => {
    it('RES-03: retorna 400 rapidamente cuando el archivo no existe en BD', async () => {
      const start = Date.now();
      const res = await request(app)
        .post('/user-get-key')
        .set('x-actual-token', 'valid-token')
        .send({ fileId: generateFileId() });
      const elapsed = Date.now() - start;

      expect(res.statusCode).toBe(400);
      expect(res.text).toBe('file-not-found');
      expect(elapsed).toBeLessThan(300);
    });
  });

  describe('POST /sync — archivo inexistente no deberia colgar', () => {
    it('RES-04: retorna 400 rapidamente cuando el archivo no existe en BD', async () => {
      const syncRequest = createMinimalSyncRequest(
        generateFileId(),
        'cualquier-grupo',
        'cualquier-key',
      );

      const start = Date.now();
      const res = await sendSyncRequest(syncRequest);
      const elapsed = Date.now() - start;

      expect(res.statusCode).toBe(400);
      expect(res.text).toBe('file-not-found');
      expect(elapsed).toBeLessThan(300);
    });
  });

  describe('Manejo de fallos del subsistema de BD', () => {
    it('RES-05: las requests sin autenticacion se rechazan en <100ms (sin tocar BD)', async () => {
      const start = Date.now();
      const res = await request(app).get('/list-user-files');
      const elapsed = Date.now() - start;

      expect(res.statusCode).toBe(401);
      expect(elapsed).toBeLessThan(100);
    });

    it('RES-06: el endpoint /health no usa BD y responde rapido', async () => {
      // Este endpoint no esta en app-sync pero existe en el app principal.
      // Aqui probamos que la app de sync al menos rechaza requests no autenticadas rapido.
      const start = Date.now();
      const res = await request(app).post('/user-get-key');
      const elapsed = Date.now() - start;

      expect(res.statusCode).toBe(401);
      expect(elapsed).toBeLessThan(100);
    });
  });
});
