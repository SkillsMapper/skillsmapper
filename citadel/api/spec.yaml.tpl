swagger: "2.0"
info:
  title: SkillsMapper API
  description: The API for the SkillsMapper application
  version: 1.0.0
schemes:
  - https
produces:
  - application/json
paths:
  /skill/lookup:
    get:
      summary: Skill Lookup
      operationId: skillLookup
      x-google-backend:
        address: ${skill_lookup_service_url}
      responses:
        '200':
          description: A successful response
          schema:
            type: string

