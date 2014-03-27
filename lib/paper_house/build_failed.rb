# encoding: utf-8

module PaperHouse
  # Exception raised if a build task fails
  class BuildFailed < ::StandardError
    attr_reader :command
    attr_reader :status

    # @private
    def initialize(command, status)
      @command = command
      @status = status
    end

    # Error message
    def message
      "Command `#{command}' failed with status #{status.exitstatus}"
    end
  end
end
