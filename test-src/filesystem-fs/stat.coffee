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

filesystemFs = new FsClient()

FileName = './stat.data.test'

describe 'filesystem-fs', ->

  describe 'stat', ->

    describe 'file does not exist', ->

      it 'should error while getting stat', (cb) ->

        filesystemFs
          .stat FileName, absolute: yes
          .catch (err) ->
            cb ok err

    describe 'file exists', ->

      before (cb) ->

        writeFile FileName, 'test', cb

      after (cb) ->

        unlink FileName, cb

      it 'should get stat for the file', (cb) ->

        filesystemFs
          .stat FileName, absolute: yes
          .then ({size, stat}) ->
            equal 4, size
            cb ok stat
          .catch (err) ->
            cb ok not err
