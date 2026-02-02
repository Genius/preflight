# Based on: https://github.com/Awayume/github-pr-tasklist-checker
# SPDX-FileCopyrightText: 2023 Awayume <dev@awayume.jp>
# SPDX-License-Identifier: MIT

module MarkdownChecklistParser
  autoload :Task, 'markdown_checklist_parser/task'

  module_function

  def parse(pr_body)
    tasklist = []
    unchecked = []

    pr_body.split("\n").each do |line|
      if Task::BASE_REGEX.match?(line)
        task = Task.new(line)
        tasklist.push(task)

        unless task.optional || task.checked
          unchecked.push(task)
        end
      end
    end

    message = ''

    if unchecked.length > 0
      message = "You should check these:\n"
      unchecked.each do |task|
        message += "> - #{task.title}\n"
      end
    end

    {
      unchecked: unchecked.size,
      message: message
    }
  end
end
