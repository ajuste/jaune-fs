/**
 * @file   NodeJS module that implements file system handler based on local file system.
 * @author Alvaro Juste <juste.alvaro@gmail.com>
 */

"use strict";

const _defaults = require("lodash").defaults;
const _mime     = require("Mime");
const _ncp      = require("ncp");
const _pathJoin = require("path").join;
const _fs       = require("fs");
const _q        = require("q");
const _stream   = require("stream");

/**
 * @function Convert to absolute path
 * @param    {String} path The path
 * @returns  {String} Converted path
 */
 const convertPathToAbsolute = function (path) {
   debugger
  return _pathJoin(process.cwd(), path);
}

/**
 * @class File system constructor.
 * @param {object} connection Accepts the connection to the file system.
 */
const FSFileSystem = function(connection) {
  this.connection = connection;
};
/**
 * Prototype
 */
FSFileSystem.prototype = {
  /**
   * @function Writes a file into file system.
   * @param    {String} path Where to write
   * @param    {Buffer|String|Stream} data Data to be written into file.
   * @param    {Boolean} [options.absolute] When true the path is not converted to absolute.
   */
  writeFile : function* (path, data, options) {

    options = _defaults(options || {}, {
      absolute : false
    });
    path = options.absolute ? path : convertPathToAbsolute(path);

    if (data instanceof _stream) {
      const defer = _q.defer();
      const write = _fs.createWriteStream(path);

      data
      .on("end", defer.resolve)
      .on("error", defer.reject);

      write.on("open", function() {
        data.pipe(write);
      })
      .on("error", defer.reject);

      return defer.promise;
    }
    else {
      return _q.nfcall(_fs.writeFile, convertPathToAbsolute(path), data);
    }
  },
  /**
   * @function Reads a file at the given path.
   * @param    {String} path The path to read file from.
   * @param    {String} [options.encoding] The encoding of the file
   * @param    {Boolean} [options.absolute] When true the path is not converted to absolute.
   */
  readFile : function* (path, options) {

    options = _defaults(options || {}, {
      encoding : "binary",
      absolute : false
    });
    path = options.absolute ? path : convertPathToAbsolute(path);

    if (options.encoding === "binary") {
      if (!(yield this.exists(path))) {
        throw new Error("file does not exists");
      };
      return _fs.createReadStream(path);
    }
    else {
      return _q.nfcall(_fs.readFile, path, options.encoding);
    }
  },
  /**
   * @function Checks if file exists.
   * @param    {path} string The path to file.
   */
  exists : function* (path) {
    //return _q.bind(_fs.exists, _fs, convertPathToAbsolute(path));
    return _q.Promise(function(resolve, reject, notify) {
      _fs.exists(path, function(exists) {
        resolve(exists);
      });
    });
  },
  /**
   * @function Copies a path into another.
   * @param    {from} string The source path.
   * @param    {to} string The destination path.
   */
  copy : function* (from, to) {
    return _q.nfcall(_ncp, convertPathToAbsolute(from), convertPathToAbsolute(to));
  },
  /**
   * @function Removes a file
   * @param    {String} path The file to be removed
   * @param    {Boolean} [options.absolute] When true the path is not converted to absolute.
   */
  removeFile : function* (path, options) {

    options = _defaults(options || {}, {
      absolute : false
    });
    path = options.absolute ? path : convertPathToAbsolute(path);
    return _q.nfcall(_fs.unlink, path);
  },
  /**
   * @function Retrieves the STAT object for a specified path.
   * @param {path} string The source path.
   * @param {function} cb Standard callback function.
   */
  stat : function* (path, cb) {
    const defer = _q.defer();
    _fs.stat(convertPathToAbsolute(path), function(err, stat) {
      if (err) {
        defer.reject(err);
      }
      defer.resolve(stat ? new FSClientStat(path, stat) : null);
    });
    return yield defer.promise;
  }
};
/**
 * @class Local file system STAT object wrapper.
 * @param {object} connection Accepts the connection to the file system.
 * @param {string} path The path of the STAT object.
 */
var FSClientStat = function(path, stat) {
  this.stat = stat;
  this.path = path;
  this.mtime = this.stat.mtime;
  this.size = this.stat.size;
};
/**
 * Prototype
 */
FSClientStat.prototype = {
  /**
   * @function Checks if STAT is a directory.
   */
  isDirectory : function() {
    return this.stat.isDirectory();
  },
  /**
   * @function Returns the MIME type of file.
   */
  getMime : function() {
    return this.isDirectory() ? "" : _mime.lookup(convertPathToAbsolute(this.path));
  }
};
module.exports = {
  FsClient : FSFileSystem
};
