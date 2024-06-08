const testController = (fastify, options, done) => {
    fastify.post('/', async (req, reply) => {
      try {
        const { club_id } = req.body; 
  
        const res = await fastify.pg.query(
          'SELECT * FROM player_role WHERE player_role.club_id = $1',
          [club_id]
        );
  
        reply.send(res.rows);
      } catch (err) {
        fastify.log.error('Error while running query:', err);
        reply.status(500).send({ error: 'An error occurred while running the query.' });
      }
    });
    
    done();
  };
  
  export default testController;

  