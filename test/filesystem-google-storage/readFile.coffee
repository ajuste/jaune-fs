{
  equal
  ok
} = require 'assert'

{
  GoogleStorageClient
} = require '../../lib/filesystem-google-storage'

{
  PassThrough
} = require 'stream'

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

  describe 'readFile', ->

    describe 'successfuly', ->

      before ->

        mockFile connection, FileNameOrigin, {

          createReadStream: (opts) ->

            @stream = s = new PassThrough()

            s.write(FileData)
            s.end()

            s

          readFile: (target, cb) ->

            equal target, FileNameTarget

            cb null, @stream
        }

        @fs = new GoogleStorageClient connection

      after stopMocks

      it 'should read an existing file', (cb) ->

        @fs
          .readFile FileNameOrigin
          .on 'data', (data) ->
            equal data.toString('utf-8'), FileData
          .on 'end', cb
          .on 'error', (err) -> cb equal null, err

    describe 'failing', ->

      before ->

        mockFile connection, FileNameOriginNonExisting, {

          createReadStream: (opts) ->

            @stream = s = new PassThrough()

            s.write(FileData)
            s.on 'pipe', -> s.emit 'error', code: 500
            s

          readFile: (target, cb) ->

            equal target, FileNameOriginNonExisting

            cb null, @stream
        }

        @fs = new GoogleStorageClient connection

      after stopMocks

      it 'should fail to read non existing file', (cb) ->

        new PassThrough().pipe(@fs
            .readFile FileNameOriginNonExisting
            .on 'error', ({code}) -> cb equal code, 500)
