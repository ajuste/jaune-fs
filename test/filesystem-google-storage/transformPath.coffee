{
  equal
} = require 'assert'

{
  GoogleStorageClient
} = require '../../lib/filesystem-google-storage'

stream = require 'stream'

connection =
  bucketName: 'free-fair-core'
  projectId: 'free-fair'
  credentials:
    project_id: 'proj-id'
    private_key: 'the-key'

describe 'filesystem-google-storage-fs', ->

  describe 'transformPath', ->

    before ->
      @fs = new GoogleStorageClient connection

    it 'should transformPath for a path starting with /', ->

      equal @fs.transformPath('////a/b/c'), 'a/b/c'

    it 'does not transform', ->

      equal @fs.transformPath('a/b/c'), 'a/b/c'
