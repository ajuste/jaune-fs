{
  equal,
  ok
} = require 'assert'

{
  mockFile
  stopMocks
} = require './mock'

{
  GoogleStorageClient
} = require '../../lib/filesystem-google-storage'

connection =
  bucketName: 'free-fair-core'
  projectId: 'free-fair'
  credentials:
    project_id: 'proj-id'
    private_key: 'the-key'

DirName = 'test/'
FileName = "#{DirName}writeFile.txt"

describe 'filesystem-google-storage-fs', ->

  describe 'removeFile', ->

    describe 'successful scenarios', ->

      before ->

        mockFile connection, FileName, {
          delete: (cb) -> cb null
        }

        @fs = new GoogleStorageClient connection

      after stopMocks

      it 'should remove an existing file', (cb) ->

        @fs
          .removeFile FileName
          .then cb
          .catch (err) -> cb equal null, err

    describe 'failing', ->

      before ->

        mockFile connection, DirName, {
          delete: (cb) -> cb code: 404
        }

        @fs = new GoogleStorageClient connection

      after stopMocks

      it 'should fail to read a directory', (cb) ->

        @fs
          .removeFile DirName
          .catch (err) -> cb equal err.code, 404
