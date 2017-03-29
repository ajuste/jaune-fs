
/**
 * @file   NodeJS module that implements file system handler based on local file system.
 * @author Alvaro Juste <juste.alvaro@gmail.com>
 */
"use strict";
var FSClientStat, FSFileSystem, convertPathToAbsolute, createReadStream, createWriteStream, exists, join, mime, ncp, readFile, ref, rename, stat, stream, unlink, writeFile;

mime = require("mime");

ncp = require("ncp");

join = require("path").join;

ref = require("fs"), createReadStream = ref.createReadStream, createWriteStream = ref.createWriteStream, exists = ref.exists, rename = ref.rename, readFile = ref.readFile, stat = ref.stat, writeFile = ref.writeFile, unlink = ref.unlink;

stream = require("stream");


/**
 * @function Convert to absolute path
 * @param    {String} path The path
 * @returns  {String} Converted path
 */

convertPathToAbsolute = function(path) {
  return join(process.cwd(), path);
};


/**
 * @class File system constructor.
 * @param {object} connection Accepts the connection to the file system.
 */

FSFileSystem = (function() {
  function FSFileSystem(connection) {
    this.connection = connection;
  }


  /**
   * @function Move a file
   * @param    {String} source Source path
   * @param    {String} target Targett path
   * @param    {Boolean} [options.absolute] When true the path is not converted to absolute.
   */

  FSFileSystem.prototype.move = function(source, target, options) {
    if (options == null) {
      options = {
        absolute: false
      };
    }
    if (!options.absolute) {
      source = convertPathToAbsolute(source);
    }
    if (!options.absolute) {
      target = convertPathToAbsolute(target);
    }
    return new Promise(function(res, rej) {
      return rename(source, target, function(err) {
        if (err == null) {
          return res();
        }
        return rej(err);
      });
    });
  };


  /**
   * @function Writes a file into file system.
   * @param    {String} path Where to write
   * @param    {Buffer|String|Stream} data Data to be written into file.
   * @param    {Boolean} [options.absolute] When true the path is not converted to absolute.
   */

  FSFileSystem.prototype.writeFile = function(path, data, options) {
    if (options == null) {
      options = {
        absolute: false
      };
    }
    if (!options.absolute) {
      path = convertPathToAbsolute(path);
    }
    return new Promise(function(res, rej) {
      var write;
      if (data instanceof stream) {
        write = createWriteStream(path);
        data.on("end", res).on("error", rej);
        return write.on("open", function() {
          return data.pipe(write);
        }).on("error", rej);
      } else {
        return writeFile(convertPathToAbsolute(path), data, function(err) {
          if (err != null) {
            return rej(err);
          }
          return res();
        });
      }
    });
  };


  /**
   * @function Reads a file at the given path.
   * @param    {String} path The path to read file from.
   * @param    {String} [options.encoding] The encoding of the file
   * @param    {Boolean} [options.absolute] When true the path is not converted to absolute.
   */

  FSFileSystem.prototype.readFile = function(path, options) {
    if (options == null) {
      options = {
        encoding: "binary",
        absolute: false
      };
    }
    if (!options.absolute) {
      path = convertPathToAbsolute(path);
    }
    return new Promise((function(_this) {
      return function(res, rej) {
        switch (options.encoding) {
          case 'binary':
            return _this.exists(path, {
              absolute: true
            }).then(function(exists) {
              if (exists) {
                return res(createReadStream(path));
              }
              return rej(new Error("file does not exists"));
            })["catch"](rej);
          default:
            return readFile(path, options.encoding, function(err, data) {
              if (err != null) {
                return rej(err);
              }
              return res(data);
            });
        }
      };
    })(this));
  };


  /**
   * @function Checks if file exists.
   * @param    {path} string The path to file.
   */

  FSFileSystem.prototype.exists = function(path, options) {
    if (options == null) {
      options = {
        absolute: false
      };
    }
    if (!options.absolute) {
      path = convertPathToAbsolute(path);
    }
    return new Promise(function(res) {
      return exists(path, res);
    });
  };


  /*
   * @function Copies a path into another.
   * @param    {from} string The source path.
   * @param    {to} string The destination path.
   */

  FSFileSystem.prototype.copy = function(from, to) {
    return new Promise(function(res, rej) {
      return ncp(convertPathToAbsolute(from), convertPathToAbsolute(to), function(err) {
        if (err != null) {
          return rej(err);
        }
        return res();
      });
    });
  };


  /**
   * @function Removes a file
   * @param    {String} path The file to be removed
   * @param    {Boolean} [options.absolute] When true the path is not converted to absolute.
   */

  FSFileSystem.prototype.removeFile = function(path, options) {
    if (options == null) {
      options = {
        absolue: false
      };
    }
    if (!options.absolute) {
      path = convertPathToAbsolute(path);
    }
    return new Promise(function(res, rej) {
      return unlink(path, function(err) {
        if (err != null) {
          return rej(err);
        }
        return res();
      });
    });
  };


  /**
   * @function Retrieves the STAT object for a specified path.
   * @param {path} string The source path.
   * @param {function} cb Standard callback function.
   */

  FSFileSystem.prototype.stat = function(path, options) {
    if (options == null) {
      options = {
        absolute: false
      };
    }
    if (!options.absolute) {
      path = convertPathToAbsolute(path);
    }
    return new Promise(function(res, rej) {
      return stat(convertPathToAbsolute(path), function(err, stat) {
        if (err != null) {
          return rej(err);
        }
        return res(new FSClientStat(path, stat));
      });
    });
  };

  return FSFileSystem;

})();


/**
 * @class Local file system STAT object wrapper.
 * @param {object} connection Accepts the connection to the file system.
 * @param {string} path The path of the STAT object.
 */

FSClientStat = (function() {
  function FSClientStat(path1, stat1) {
    var ref1;
    this.path = path1;
    this.stat = stat1;
    ref1 = this.stat, this.mtime = ref1.mtime, this.size = ref1.size;
  }


  /**
   * @function Checks if STAT is a directory.
   */

  FSClientStat.prototype.isDirectory = function() {
    return this.stat.isDirectory();
  };


  /**
   * @function Returns the MIME type of file.
   */

  FSClientStat.prototype.getMime = function() {
    if (this.isDirectory()) {
      return "";
    } else {
      return _mime.lookup(convertPathToAbsolute(this.path));
    }
  };

  return FSClientStat;

})();

module.exports = {
  FsClient: FSFileSystem
};
