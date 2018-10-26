class AddExtraJob < ApplicationJob
  queue_as :default

  def perform(times)
    Graph::Citation # Need this here because rails doesn't seem to autoload it for some reason
    cypher = "MATCH ()-[r:`GRAPH::CITATION`]->() WHERE NOT EXISTS(r.extra) RETURN r LIMIT #{times}"

    res = Neo4j::ActiveBase.current_session.query(cypher)

    res.structs.map(&:r).each_with_index do |citation, i|
      from = citation.from_node
      to = citation.to_node

      extra = from.related.include?(to)
      citation.extra = extra
      citation.save!

      Rails.logger.info "#{i}: #{from.reference}-[#{extra}]-#{to.reference}"
    end
  end
end
