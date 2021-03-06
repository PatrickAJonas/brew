require "hbc/utils"

require "hbc/container/base"
require "hbc/container/air"
require "hbc/container/bzip2"
require "hbc/container/cab"
require "hbc/container/dmg"
require "hbc/container/self_extracting_executable"
require "hbc/container/executable"
require "hbc/container/generic_unar"
require "hbc/container/gzip"
require "hbc/container/lzma"
require "hbc/container/naked"
require "hbc/container/otf"
require "hbc/container/pkg"
require "hbc/container/seven_zip"
require "hbc/container/sit"
require "hbc/container/svn_repository"
require "hbc/container/tar"
require "hbc/container/ttf"
require "hbc/container/rar"
require "hbc/container/xar"
require "hbc/container/xz"
require "hbc/container/zip"

module Hbc
  class Container
    def self.autodetect_containers
      [
        Pkg,
        Ttf,
        Otf,
        Air,
        SelfExtractingExecutable,
        Cab,
        Dmg,
        SevenZip,
        Sit,
        Rar,
        Zip,
        Xar,   # need to be before tar as tar can also list xar
        Tar,   # or compressed tar (bzip2/gzip/lzma/xz)
        Bzip2, # pure bzip2
        Gzip,  # pure gzip
        Lzma,  # pure lzma
        Xz,    # pure xz
        Executable,
        SvnRepository,
      ]
      # for explicit use only (never autodetected):
      # Hbc::Container::Naked
      # Hbc::Container::GenericUnar
    end

    def self.for_path(path)
      odebug "Determining which containers to use based on filetype"

      magic_number = if path.directory?
        ""
      else
        File.binread(path, 262) || ""
      end

      autodetect_containers.find do |c|
        odebug "Checking container class #{c}"
        c.can_extract?(path: path, magic_number: magic_number)
      end
    end

    def self.from_type(type)
      odebug "Determining which containers to use based on 'container :type'"
      begin
        const_get(type.to_s.split("_").map(&:capitalize).join)
      rescue NameError
        nil
      end
    end
  end
end
