import Fastify from 'fastify';
import dbConfig from './db.config.js';
import pg from '@fastify/postgres';
import testController from './controllers/testcontroller.js';
import ip from 'ip';

const fastify = Fastify({
  logger: true,
  trustProxy: true
})

fastify.register(pg, {
  connectionString: `postgres://${dbConfig.user}:${dbConfig.password}@${dbConfig.host}:${dbConfig.port}/${dbConfig.database}`
});

fastify.register(testController, { prefix: '/test' });

const ipAddr = ip.address();
fastify.listen({ port: 8000, host: ipAddr })
  .then(() => console.log(`server listening on ${fastify.server.address().port}`))
  .catch(err => {
    throw err;
  });

