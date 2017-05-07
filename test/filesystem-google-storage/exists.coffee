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

FileNameOrigin = 'writeFile.txt'
FileNameOriginNonExisting = 'writeFile.123.txt'
FileData = 'this is the data !@# \u1F607'

describe 'filesystem-google-storage-fs', ->

  describe 'exists', ->

    context 'failing', ->

      describe 'error thrown', ->

        before ->

          mockFile connection, FileNameOrigin, {
            exists: (cb) ->
              cb code: 500
          }

          @fs = new GoogleStorageClient connection

        after stopMocks

        it 'should check an existing file', (cb) ->

          @fs
            .exists FileNameOrigin
            .then (data) -> cb ok no
            .catch (err) ->
              ok err
              cb equal err.code, 500

    context 'successful', ->

      describe 'existing', ->

        before ->

          mockFile connection, FileNameOrigin, {
            exists: (cb) ->
              cb null, yes
          }

          @fs = new GoogleStorageClient connection

        after stopMocks

        it 'should check an existing file', (cb) ->

          @fs
            .exists FileNameOrigin
            .then (data) -> cb equal yes, data
            .catch (err) -> cb equal null, err

      describe 'not existing', ->

        before ->

          mockFile connection, FileNameOriginNonExisting, {
            exists: (cb) ->
              cb null, no
          }

          @fs = new GoogleStorageClient connection

        after stopMocks

        it 'should check non existing file', (cb) ->

          @fs
            .exists FileNameOriginNonExisting
            .then (data) -> cb equal no, data
            .catch (err) -> cb equal null, err
