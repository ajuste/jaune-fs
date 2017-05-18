var FsClient, GoogleStorageClient, Manager, ReadResult, S3Bucket, ref;

ref = require('./filesystem-manager'), Manager = ref.Manager, ReadResult = ref.ReadResult;

FsClient = require('./filesystem-fs').FsClient;

S3Bucket = require('./filesystem-s3').S3Bucket;

GoogleStorageClient = require('./filesystem-google-storage').GoogleStorageClient;

module.exports = {
  Manager: Manager,
  ReadResult: ReadResult,
  FsClient: FsClient,
  S3Bucket: S3Bucket,
  GoogleStorageClient: GoogleStorageClient
};
