{
  equal,
  ok
} = require 'assert'

{
    writeFile
    unlink
} = require 'fs'

{
  FsClient
} = require '../../lib/filesystem-fs'

stream = require 'stream'

filesystemFs = new FsClient()

FileName = './readFile.data.test'

describe 'filesystem-fs', ->

  describe 'readFile', ->

    describe 'file does not exist', ->

      it 'should error while openning file', (cb) ->

        filesystemFs
          .readFile FileName, absolute: yes
          .catch (err) ->
            cb ok err

    describe 'file exists', ->

      before (cb) ->

        writeFile FileName, 'test', cb

      after (cb) ->

        unlink FileName, cb

      it 'should get content for the file', (cb) ->

        filesystemFs
          .readFile FileName, absolute: yes
          .then (data) ->
            cb equal 'test', data
          .catch (err) ->
            cb ok not err

      it 'should get content for binary file', (cb) ->

        filesystemFs
          .readFile FileName, {absolute: yes, encoding: 'binary'}
          .then (data) ->
            cb ok data instanceof stream
          .catch (err) ->
            cb equal null, err
