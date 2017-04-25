
/**
 * @file   NodeJS module that implements file system handler based on S3 Buckets
 * @author Alvaro Juste <juste.alvaro@gmail.com>
 */
"use strict";
var FsClient, Stat, mime;

mime = require("mime");


/**
 * @class File system constructor.
 * @param {object} connection Accepts the connection to the file system.
 */

FsClient = (function() {
  function FsClient(connection) {
    var AWS;
    this.connection = connection;
    AWS = require('aws-sdk');
    this.s3 = new AWS.S3(this.connection);
  }


  /**
   * @function Move a file
   * @param    {String} source Source key
   * @param    {String} target Targett key
   */

  FsClient.prototype.move = function(source, target) {
    var params;
    params = {
      Bucket: this.connection.bucket,
      Key: source
    };
    return this.copy(source, target).then(new Promise(res, rej)(function() {
      return s3.deleteObject(params, function(err) {
        if (err != null) {
          return rej(err);
        } else {
          return res();
        }
      });
    }));
  };


  /**
   * @function Writes a file bucket
   * @param    {String} path Is the key
   * @param    {Buffer|String|Stream} data Data to be written into file.
   */

  FsClient.prototype.writeFile = function(path, data) {
    return new Promise(function(res, rej) {
      var params;
      params = {
        Bucket: this.connection.bucket,
        Key: path,
        Body: data
      };
      return s3.putObject(params, function(err, data) {
        if (err != null) {
          return rej(err);
        } else {
          return res(data);
        }
      });
    });
  };


  /**
   * @function Reads an object
   * @param    {String} path The key of the object
   */

  FsClient.prototype.readFile = function(path) {
    return new Promise(function(res, rej) {
      var params;
      params = {
        Bucket: this.connection.bucket,
        Key: path
      };
      return s3.getObject(params, function(err, data) {
        if (err != null) {
          return rej(err);
        } else {
          return res(data);
        }
      });
    });
  };


  /**
   * @function Checks if file exists.
   * @param    {path} string The key
   */

  FsClient.prototype.exists = function(path) {
    return new Promise((function(_this) {
      return function(res, rej) {
        return _this.stat(path, function(err, data) {
          if (err != null) {
            if (err.code === 'NotFound') {
              return res(false);
            }
            return rej(err);
          }
          return res(true);
        });
      };
    })(this));
  };


  /*
   * @function Copies a path into another.
   * @param    {from} string The source key.
   * @param    {to} string The destination key.
   */

  FsClient.prototype.copy = function(from, to) {
    var params;
    params = {
      Bucket: this.connection.bucket,
      Key: target,
      CopySource: source
    };
    return new Promise(function(res, rej) {
      return s3.copyObject(params, function(err) {
        if (err != null) {
          return rej(err);
        } else {
          return res(data);
        }
      });
    });
  };


  /**
   * @function Removes a file
   * @param    {String} path The file to be removed
   * @param    {Boolean} [options.absolute] When true the path is not
   *           converted to absolute.
   */

  FsClient.prototype.removeFile = function(path, options) {
    var params;
    if (options == null) {
      options = {
        absolue: false
      };
    }
    params = {
      Bucket: this.connection.bucket,
      Key: path
    };
    return new Promise(function(res, rej) {
      return s3.deleteObject(params, function(err, data) {
        if (err != null) {
          return rej(err);
        } else {
          return res(data);
        }
      });
    });
  };


  /**
   * @function Retrieves the STAT object for a specified path.
   * @param {path} string The source path.
   * @param {function} cb Standard callback function.
   */

  FsClient.prototype.stat = function(path, cb) {
    return new Promise(function(res, rej) {
      return s3.headObject(params, function(err, data) {
        return s3.copyObject(params, function(err) {
          if (err != null) {
            if (err.code === 'NotFound') {
              return res(false);
            }
            return rej(err);
          }
          return res(true);
        });
      });
    });
  };

  return FsClient;

})();


/**
 * @class Stat wrapper
 * @param {object} head The head object
 */

Stat = (function() {
  function Stat() {}

  constructor(function(head) {
    this.head = head;
  });


  /**
   * @function Checks if STAT is a directory.
   */

  Stat.prototype.isDirectory = function() {
    return false;
  };


  /**
   * @function Returns the MIME type of file.
   */

  Stat.prototype.getMime = function() {
    return this.head.ContentEncoding;
  };

  return Stat;

})();

module.exports = {
  S3Bucket: FsClient
};
