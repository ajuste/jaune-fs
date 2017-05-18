{
  equal,
  ok
} = require 'assert'

lib = require '../../'

describe 'lib/index', ->

  it 'exports expected properties', ->
    ok lib
    ok lib.FsClient
    ok lib.GoogleStorageClient
    ok lib.S3Bucket
    ok lib.Manager
    ok lib.ReadResult

  it 'contains no more properties than expected', ->

    equal 5, Object.getOwnPropertyNames(lib).length
