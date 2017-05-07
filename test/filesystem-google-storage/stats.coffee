{
  equal,
  ok
} = require 'assert'

{
  GoogleStorageClient
} = require '../../lib/filesystem-google-storage'

{
  mockFile
  stopMocks
} = require './mock'

connection =
  bucketName: 'free-fair-core'
  projectId: 'free-fair'
  credentials:
    project_id: 'proj-id'
    private_key: 'the-key'

DirName = 'test/'
FileName = "#{DirName}writeFile.txt"
FileNameNonExisting = 'writeFile.123.txt'
FileData = 'this is the data !@# \u1F607'

describe 'filesystem-google-storage-fs', ->

  describe 'stat', ->

    describe 'successfuly', ->

      before ->

        mockFile connection, FileName, {
          getMetadata: (cb) ->
            cb null, contentType: 'text/plain', size: 25
        }

        @fs = new GoogleStorageClient connection

      after stopMocks

      it 'should stat an existing file', (cb) ->

        @fs
          .stat FileName
          .then (stat) ->
            ok stat
            equal stat.getSize(), 25
            equal stat.getMime(), 'text/plain'
            cb()
          .catch (err) -> cb equal null, err

    describe 'failing', ->

      before ->

        mockFile connection, FileNameNonExisting, {
          getMetadata: (cb) -> cb code: 404
        }

        @fs = new GoogleStorageClient connection

      after stopMocks

      it 'should fail to read non existing file', (cb) ->

        @fs
          .stat FileNameNonExisting
          .catch (err) ->
            ok err
            cb equal err.code, 404
