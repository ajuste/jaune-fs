
/**
 * @file   NodeJS module that implements file system handler based on Google
 *         storage
 * @author Alvaro Juste <juste.alvaro@gmail.com>
 */
"use strict";
var GoogleStorageClient, Stat, Stream, mime;

mime = require("mime");

Stream = require("stream");


/**
 * @class File system constructor.
 * @param {object} connection Accepts the connection to the file system.
 */

GoogleStorageClient = (function() {

  /**
  * @constructor Constructs a new filesystem connection to google cloud storage
  * @param {Object} connection The connection which contains the following data
  *                 {
  *                   credentials: {client_email, private_key},
  *                   projectId,
  *                   bucketName,
  *                 }
   */
  function GoogleStorageClient(connection) {
    this.connection = connection;
    this.storage = require('@google-cloud/storage')(this.connection);
    this.bucket = this.storage.bucket(this.connection.bucketName);
  }

  GoogleStorageClient.prototype.file = function(path) {
    return this.bucket.file(path);
  };


  /**
   * @function Move a file
   * @param    {String} source Source key
   * @param    {String} target Targett key
   * @returns  {Promise}
   */

  GoogleStorageClient.prototype.move = function(source, target) {
    return new Promise((function(_this) {
      return function(res, rej) {
        return _this.file(source).move(target, function(err) {
          if (err != null) {
            return rej(err);
          } else {
            return res();
          }
        });
      };
    })(this));
  };


  /**
   * @function Writes a file bucket
   * @param    {String} path Is the key
   * @param    {Buffer|String|Stream} data Data to be written into file.
   * @param    {Object} options Extra options
   * @param    {String}
   * @returns  {Promise}
   */

  GoogleStorageClient.prototype.writeFile = function(path, data) {
    return new Promise((function(_this) {
      return function(res, rej) {
        var inputStream;
        inputStream = _this.file(path).createWriteStream({
          metadata: {
            contentType: mime.lookup(path)
          }
        }).on('error', rej).on('finish', res);
        if (data instanceof Stream) {
          return data.pipe(inputStream);
        } else {
          return inputStream.end(data);
        }
      };
    })(this));
  };


  /**
   * @function Reads an object
   * @param    {String} path The key of the object
   * @returns  {Stream}
   */

  GoogleStorageClient.prototype.readFile = function(path) {
    return new Promise((function(_this) {
      return function(res) {
        return res(_this.file(path).createReadStream());
      };
    })(this));
  };


  /**
   * @function Checks if file exists.
   * @param    {path} string The key
   * @returns  {Promise}
   */

  GoogleStorageClient.prototype.exists = function(path) {
    return new Promise((function(_this) {
      return function(res, rej) {
        return _this.file(path).exists(function(err, exists) {
          if (err != null) {
            return rej(err);
          } else {
            return res(exists);
          }
        });
      };
    })(this));
  };


  /*
   * @function Copies a path into another.
   * @param    {from} string The source key.
   * @param    {to} string The destination key.
   * @returns  {Promise}
   */

  GoogleStorageClient.prototype.copy = function(from, to) {
    return new Promise((function(_this) {
      return function(res, rej) {
        return _this.file(from).copy(to, function(err, exists) {
          if (err != null) {
            return rej(err);
          } else {
            return res();
          }
        });
      };
    })(this));
  };


  /**
   * @function Removes a file
   * @param    {String} path The file to be removed
   * @param    {Boolean} [options.absolute] When true the path is not
   *           converted to absolute.
   * @returns  {Promise}
   */

  GoogleStorageClient.prototype.removeFile = function(path) {
    return new Promise((function(_this) {
      return function(res, rej) {
        return _this.file(path)["delete"](function(err) {
          if (err != null) {
            return rej(err);
          } else {
            return res();
          }
        });
      };
    })(this));
  };


  /**
   * @function Retrieves the STAT object for a specified path.
   * @param {path} string The source path.
   * @param {function} cb Standard callback function.
   * @returns  {Promise}
   */

  GoogleStorageClient.prototype.stat = function(path) {
    return new Promise((function(_this) {
      return function(res, rej) {
        return _this.file(path).getMetadata(function(err, meta) {
          if (err != null) {
            return rej(err);
          } else {
            return res(new Stat(meta));
          }
        });
      };
    })(this));
  };

  return GoogleStorageClient;

})();


/**
 * @class Stat wrapper
 * @param {object} head The head object
 */

Stat = (function() {
  function Stat(meta1) {
    this.meta = meta1;
  }


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
    return this.meta.contentType;
  };


  /**
   * @function Get size of file in bytes
   */

  Stat.prototype.getSize = function() {
    return this.meta.size;
  };

  return Stat;

})();

module.exports = {
  GoogleStorageClient: GoogleStorageClient
};
