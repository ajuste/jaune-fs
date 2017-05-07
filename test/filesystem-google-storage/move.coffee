{
  equal
  ok
} = require 'assert'

{
  GoogleStorageClient
} = require '../../lib/filesystem-google-storage'

{
  mockFile
  stopMocks
} = require './mock'

stream = require 'stream'

connection =
  bucketName: 'free-fair-core'
  projectId: 'free-fair'
  credentials:
    project_id: 'proj-id'
    private_key: 'the-key'

FileNameOrigin = 'writeFile.txt'
FileNameOriginNonExisting = 'writeFile.123.txt'
FileNameTarget = 'writeFile.target.txt'
FileData = 'this is the data !@# \u1F607'

describe 'filesystem-google-storage-fs', ->

  describe 'move', ->

    describe 'successfuly', ->

      before ->

        mockFile connection, FileNameOrigin, {
          move: (path, cb) ->
            equal path, FileNameTarget
            cb null
        }

        @fs = new GoogleStorageClient connection

      after stopMocks

      it 'should move an existing file', (cb) ->

        @fs
          .move FileNameOrigin, FileNameTarget
          .then cb
          .catch (err) ->
            cb ok not err

    describe 'failing', ->

      before ->

        mockFile connection, FileNameOriginNonExisting, {
          move: (path, cb) ->
            equal path, FileNameTarget
            cb code: 500
        }

        @fs = new GoogleStorageClient connection

      after stopMocks

      it 'should fail to move non existing file', (cb) ->

        @fs
          .move FileNameOriginNonExisting, FileNameTarget
          .then -> cb ok no
          .catch (err) ->
            ok err
            cb equal err.code, 500
