module Neo4j
  class SessionManager
    class << self
      def open_neo4j_session(type, url_or_path, wait_for_connection = false, options = {})
        enable_unlimited_strength_crypto! if java_platform? && session_type_is_embedded?(type)

        adaptor = cypher_session_adaptor(type, url_or_path, options.merge(wrap_level: :proc))
        session = Neo4j::Core::CypherSession.new(adaptor)
        wait_and_retry(session) if wait_for_connection
        session
      end

      protected

      def wait_and_retry(session)
        logger = Neo4j::Config[:logger]
        Timeout.timeout(60) do
          begin
            logger.fatal ?.
            session.constraints
          rescue Neo4j::Core::CypherSession::ConnectionFailedError
            sleep(1)
            retry
          end
        end
      rescue Timeout::Error
        raise Timeout::Error, 'Timeout while waiting for connection to neo4j database'
      end
    end
  end
end
