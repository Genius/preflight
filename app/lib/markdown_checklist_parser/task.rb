# Based on: https://github.com/Awayume/github-pr-tasklist-checker
# SPDX-FileCopyrightText: 2023 Awayume <dev@awayume.jp>
# SPDX-License-Identifier: MIT

module MarkdownChecklistParser
  class Task
    BASE_REGEX = /- +\[.\] +/
    CHECKED_REGEX = /- +\[x\] +.+/i
    CHOICE_REGEX = /Choice(#.+)?/
    COMMENT_REGEX = /<!--.*?-->/
    OPTIONS_REGEX = /<!-- +.+ +-->/
    OPTIONS_START = '<!--'
    OPTIONS_END = '-->'

    attr_reader :title, :checked, :optional, :choosable, :choice_id, :multiple_choosable
    attr_accessor :children

    def initialize(line)
      line = line.strip

      @title = line
                 .sub(BASE_REGEX, '')
                 .gsub(COMMENT_REGEX, '')
                 .strip

      @checked = CHECKED_REGEX.match?(line)

      @params = parse_params(line)

      @optional = @params.include?('Optional')
      @choosable = @params.any? { |elm| CHOICE_REGEX.match?(elm) }
      @choice_id = @params.find { |elm| CHOICE_REGEX.match?(elm) }&.gsub(/Choice(#)?/, '')
      @multiple_choosable = @params.include?('multiple')
      @children = []
    end

    private

    def parse_params(line)
      match = line.match(OPTIONS_REGEX)
      return [] unless match

      match[0]
        .gsub(OPTIONS_START, '')
        .gsub(OPTIONS_END, '')
        .strip
        .split(',')
        .map(&:strip)
    end
  end
end
