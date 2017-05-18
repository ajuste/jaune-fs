{
  Manager
  ReadResult
} = require './filesystem-manager'
{
  FsClient
} = require './filesystem-fs'
{
  S3Bucket
} = require './filesystem-s3'
{
  GoogleStorageClient
} = require './filesystem-google-storage'

module.exports = {Manager, ReadResult, FsClient, S3Bucket, GoogleStorageClient}
