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

  describe 'copy', ->

    describe 'successfuly', ->

      before ->

        mockFile connection, FileNameOrigin, {
          copy: (target, cb) ->
            equal target, FileNameTarget
            cb null
        }

        @fs = new GoogleStorageClient connection

      after stopMocks

      it 'should copy an existing file', (cb) ->

        @fs
          .copy FileNameOrigin, FileNameTarget
          .then cb
          .catch (err) ->
            cb ok not err

    describe 'failing', ->

      before ->

        mockFile connection, FileNameOriginNonExisting,
          copy: (target, cb) ->
            equal target, FileNameTarget
            cb code: 404

        @fs = new GoogleStorageClient connection

      after stopMocks

      it 'should fail to copy non existing file', (cb) ->

        @fs
          .copy FileNameOriginNonExisting, FileNameTarget
          .then -> cb ok no
          .catch (err) ->
            ok err
            cb equal err.code, 404
