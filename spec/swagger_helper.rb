# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      components: {
        securitySchemes: {
          Bearer: {
            type: :http,
            scheme: :bearer,
            bearerFormat: :JWT
          }
        }
      },
       servers: [
        {
          url: 'http://localhost:3000',
          description: 'Local Development Server'
        },
        {
          url: 'https://{defaultHost}',
          description: 'Production Server',
          variables: {
            defaultHost: {
              default: 'www.example.com'
            }
          }
        }
      ]

    }
  }

  config.openapi_format = :yaml
end
