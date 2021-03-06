# encoding: utf-8

require 'paper_house/auto_depends'
require 'paper_house/build_failed'
require 'paper_house/cc_options'
require 'paper_house/dependency'
require 'rake/clean'
require 'rake/tasklib'

module PaperHouse
  # Common base class for *.c compilation tasks.
  class BuildTask < Rake::TaskLib
    # Helper class for defining CLEAN and CLOBBER.
    class CleanTask
      def initialize(targets, file_list)
        @targets = targets
        @file_list = Object.const_get(file_list.to_s.upcase)
        define_task
      end

      private

      def define_task
        @targets.each do |each|
          next if @file_list.include?(each)
          @file_list.include each
        end
        @file_list.existing!
      end
    end

    include CcOptions

    # Name of task.
    attr_accessor :name

    # @!attribute target_directory
    #   Directory where *.o files are created.
    attr_writer :target_directory

    def target_directory
      @target_directory ||= '.'
    end

    # @!attribute cc
    #   C compiler name or path.
    attr_writer :cc

    def cc
      ENV['CC'] || @cc || 'gcc'
    end

    def initialize(name, &block)
      @name = name.to_s
      block.call self if block
      define
    end

    # Relative path to target file.
    def target_path
      File.join target_directory, target_file_name.to_s
    end

    private

    def define
      define_main_task
      define_directory_task
      define_all_c_compile_tasks
      define_maybe_generate_target_task
      define_clean_tasks
    end

    def define_main_task
      path = target_path
      task name => [target_directory, path]
    end

    def define_directory_task
      directory target_directory
    end

    def define_all_c_compile_tasks
      sources_list.zip(objects) do |source, object|
        define_c_compile_task source, object
      end
    end

    def define_c_compile_task(source, object)
      task object => source do |task|
        compile task.name, task.prerequisites[0]
      end
    end

    def define_maybe_generate_target_task
      file target_path => objects do |task|
        next if uptodate?(task.name, task.prerequisites)
        build
      end
    end

    def build
      check_sources_list
      generate_target
    end

    def check_sources_list
      fail "Cannot find sources (#{@sources})." if sources_list.empty?
    end

    def define_clean_tasks
      CleanTask.new objects, :clean
      CleanTask.new clobber_targets, :clobber
    end

    def clobber_targets
      [target_path, dependency.path]
    end

    def objects
      sources_list.pathmap File.join(target_directory, '%n.o')
    end

    def compile(o_file, c_file)
      return if no_need_to_compile?(o_file, c_file)
      auto_depends = AutoDepends.new(c_file, o_file, cc, ad_cc_options)
      auto_depends.run
      dependency.write o_file, auto_depends.data
    end

    def no_need_to_compile?(o_file, c_file)
      uptodate?(o_file, dependency.read(o_file) << c_file)
    end

    def ad_cc_options
      (cflags + ['-fPIC'] + i_options).join ' '
    end

    def dependency
      @dependency ||= Dependency.new(@name)
    end

    def generate_target
      command = ([cc] + cc_options).join(' ')
      sh(command) do |ok, status|
        ok || fail(BuildFailed.new(command, status))
      end
    end
  end
end
