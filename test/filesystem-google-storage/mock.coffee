mock = require 'mock-require'

{
  equal
} = require 'assert'

module.exports =

  mockFile: (connection, filePath, exportable) ->

    mock '@google-cloud/storage', (con) ->

      equal con, connection

      bucket: (bucketName) ->

        equal bucketName, connection.bucketName

        file: (source) ->

          equal source, filePath

          exportable

  stopMocks: -> mock.stopAll()
