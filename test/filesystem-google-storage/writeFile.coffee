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

{
  PassThrough
} = require 'stream'

stream = require 'stream'

connection =
  bucketName: 'free-fair-core'
  projectId: 'free-fair'
  credentials:
    project_id: 'proj-id'
    private_key: 'the-key'

FileNameStr = 'test/test/writeFile.str.txt'
FileNameBuf = 'writeFile.buf.txt'
FileNameStream = 'writeFile.stream.txt'
FileData = 'this is the data !@#'

describe 'filesystem-google-storage-fs', ->

  describe 'writeFile', ->

    context 'successfuly', ->

      describe 'strings', ->

        before ->

          mockFile connection, FileNameStr,

            createWriteStream: (opts) ->

              equal opts.metadata.contentType, 'text/plain'

              @stream = s = new PassThrough()

          @fs = new GoogleStorageClient connection

        after stopMocks

        it 'should save string content', (cb) ->

          @fs
            .writeFile FileNameStr, FileData
            .then cb
            .catch (err) -> cb ok not err

      describe 'buffer', ->

        before ->

          mockFile connection, FileNameBuf,

            createWriteStream: (opts) ->

              equal opts.metadata.contentType, 'text/plain'

              @stream = s = new PassThrough()

          @fs = new GoogleStorageClient connection

        after stopMocks

        it 'should save buffer content', (cb) ->

          @fs
            .writeFile FileNameBuf, new Buffer FileData
            .then cb
            .catch (err) -> cb ok not err

      describe 'stream', ->

        before ->

          mockFile connection, FileNameStream,

            createWriteStream: (opts) ->

              equal opts.metadata.contentType, 'text/plain'

              @stream = s = new PassThrough()

          @fs = new GoogleStorageClient connection

        after stopMocks

        it 'should save stream content', (cb) ->

          s = new PassThrough()

          s.write(FileData)
          s.end()

          @fs
            .writeFile FileNameStream, s
            .then cb
            .catch (err) -> cb ok not err
