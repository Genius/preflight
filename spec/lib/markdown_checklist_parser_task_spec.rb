require 'rails_helper'

RSpec.describe MarkdownChecklistParser::Task do
  describe '#initialize' do
    context 'with basic tasks' do
      it 'parses a simple unchecked task' do
        task = MarkdownChecklistParser::Task.new('- [ ] Simple task')

        expect(task.title).to eq('Simple task')
        expect(task.checked).to be false
        expect(task.optional).to be false
        expect(task.choosable).to be false
        expect(task.choice_id).to be_nil
        expect(task.multiple_choosable).to be false
        expect(task.children).to eq([])
      end

      it 'parses a simple checked task' do
        task = MarkdownChecklistParser::Task.new('- [x] Checked task')

        expect(task.title).to eq('Checked task')
        expect(task.checked).to be true
      end

      it 'parses checked task with uppercase X' do
        task = MarkdownChecklistParser::Task.new('- [X] Checked task')

        expect(task.checked).to be true
      end

      it 'handles extra spaces in checkbox' do
        task = MarkdownChecklistParser::Task.new('-   [x]   Task with spaces')

        expect(task.title).to eq('Task with spaces')
        expect(task.checked).to be true
      end

      it 'strips leading and trailing whitespace from line' do
        task = MarkdownChecklistParser::Task.new('  - [ ] Task with whitespace  ')

        expect(task.title).to eq('Task with whitespace')
      end
    end

    context 'with optional tasks' do
      it 'identifies optional task' do
        task = MarkdownChecklistParser::Task.new('- [ ] Optional task <!-- Optional -->')

        expect(task.title).to eq('Optional task')
        expect(task.optional).to be true
      end

      it 'removes comment from title' do
        task = MarkdownChecklistParser::Task.new('- [ ] Task with comment <!-- Optional -->')

        expect(task.title).to eq('Task with comment')
        expect(task.title).not_to include('<!--')
      end

      it 'handles optional with extra spaces in comment' do
        task = MarkdownChecklistParser::Task.new('- [ ] Task <!--   Optional   -->')

        expect(task.optional).to be true
      end
    end

    context 'with choice tasks' do
      it 'identifies choice task without ID' do
        task = MarkdownChecklistParser::Task.new('- [ ] Choice option <!-- Choice -->')

        expect(task.choosable).to be true
        expect(task.choice_id).to eq('')
      end

      it 'identifies choice task with ID' do
        task = MarkdownChecklistParser::Task.new('- [ ] Choice option <!-- Choice#group1 -->')

        expect(task.choosable).to be true
        expect(task.choice_id).to eq('group1')
      end

      it 'extracts choice ID correctly' do
        task = MarkdownChecklistParser::Task.new('- [ ] Option A <!-- Choice#my-group -->')

        expect(task.choice_id).to eq('my-group')
      end

      it 'handles choice without hash symbol' do
        task = MarkdownChecklistParser::Task.new('- [ ] Option <!-- Choice123 -->')

        expect(task.choosable).to be true
        expect(task.choice_id).to eq('123')
      end
    end

    context 'with multiple choice tasks' do
      it 'identifies multiple choosable task' do
        task = MarkdownChecklistParser::Task.new('- [ ] Multiple option <!-- Choice#group1, multiple -->')

        expect(task.choosable).to be true
        expect(task.choice_id).to eq('group1')
        expect(task.multiple_choosable).to be true
      end

      it 'handles multiple flag without choice group' do
        task = MarkdownChecklistParser::Task.new('- [ ] Task <!-- multiple -->')

        expect(task.multiple_choosable).to be true
        expect(task.choosable).to be false
      end
    end

    context 'with combined options' do
      it 'handles optional choice task' do
        task = MarkdownChecklistParser::Task.new('- [ ] Optional choice <!-- Optional, Choice#group1 -->')

        expect(task.optional).to be true
        expect(task.choosable).to be true
        expect(task.choice_id).to eq('group1')
      end

      it 'handles optional multiple choice task' do
        task = MarkdownChecklistParser::Task.new('- [ ] Option <!-- Optional, Choice#g1, multiple -->')

        expect(task.optional).to be true
        expect(task.choosable).to be true
        expect(task.choice_id).to eq('g1')
        expect(task.multiple_choosable).to be true
      end

      it 'handles all options combined' do
        task = MarkdownChecklistParser::Task.new('- [x] Full option <!-- Optional, Choice#test, multiple -->')

        expect(task.checked).to be true
        expect(task.optional).to be true
        expect(task.choosable).to be true
        expect(task.choice_id).to eq('test')
        expect(task.multiple_choosable).to be true
      end

      it 'ignores order of options' do
        task = MarkdownChecklistParser::Task.new('- [ ] Task <!-- multiple, Optional, Choice#abc -->')

        expect(task.optional).to be true
        expect(task.choosable).to be true
        expect(task.multiple_choosable).to be true
      end
    end

    context 'with edge cases' do
      it 'handles task with no options comment' do
        task = MarkdownChecklistParser::Task.new('- [ ] Simple task')

        expect(task.optional).to be false
        expect(task.choosable).to be false
        expect(task.multiple_choosable).to be false
      end

      it 'handles task with empty comment' do
        task = MarkdownChecklistParser::Task.new('- [ ] Task <!--  -->')

        expect(task.optional).to be false
        expect(task.choosable).to be false
      end

      it 'handles task with non-option comment' do
        task = MarkdownChecklistParser::Task.new('- [ ] Task <!-- Some random comment -->')

        expect(task.optional).to be false
        expect(task.choosable).to be false
      end

      context 'with multiple comments' do
        it 'only the last properly formatted comment should be parsed' do
          task = MarkdownChecklistParser::Task.new('- [ ] Task <!-- Comment 1 --> text <!-- Optional -->')

          expect(task.title).to eq('Task  text')
        end
      end

      it 'preserves special characters in title' do
        task = MarkdownChecklistParser::Task.new('- [ ] Task with special chars: @#$%^&*()')

        expect(task.title).to eq('Task with special chars: @#$%^&*()')
      end

      it 'handles very long choice IDs' do
        task = MarkdownChecklistParser::Task.new('- [ ] Task <!-- Choice#very-long-group-identifier-12345 -->')

        expect(task.choice_id).to eq('very-long-group-identifier-12345')
      end

      it 'handles numeric choice IDs' do
        task = MarkdownChecklistParser::Task.new('- [ ] Task <!-- Choice#123 -->')

        expect(task.choice_id).to eq('123')
      end
    end

    context 'with children' do
      it 'initializes with empty children array' do
        task = MarkdownChecklistParser::Task.new('- [ ] Parent task')

        expect(task.children).to be_an(Array)
        expect(task.children).to be_empty
      end

      it 'allows adding children' do
        parent = MarkdownChecklistParser::Task.new('- [ ] Parent')
        child = MarkdownChecklistParser::Task.new('- [ ] Child')

        parent.children << child

        expect(parent.children.length).to eq(1)
        expect(parent.children.first).to eq(child)
      end

      it 'allows multiple children' do
        parent = MarkdownChecklistParser::Task.new('- [ ] Parent')
        child1 = MarkdownChecklistParser::Task.new('- [ ] Child 1')
        child2 = MarkdownChecklistParser::Task.new('- [ ] Child 2')

        parent.children.push(child1, child2)

        expect(parent.children.length).to eq(2)
      end
    end

    context 'with whitespace variations' do
      it 'handles tab characters after checkbox' do
        task = MarkdownChecklistParser::Task.new("- [ ] Task with tab")

        expect(task.title).to eq('Task with tab')
      end

      it 'strips leading whitespace from entire line' do
        task = MarkdownChecklistParser::Task.new("\t- [ ] Task with leading tab")

        expect(task.title).to eq('Task with leading tab')
      end

      it 'handles multiple spaces in title' do
        task = MarkdownChecklistParser::Task.new('- [ ] Task    with    spaces')

        expect(task.title).to eq('Task    with    spaces')
      end

      it 'handles newline characters' do
        task = MarkdownChecklistParser::Task.new("- [ ] Task\n")

        expect(task.title).to eq('Task')
      end
    end

    context 'BASE_REGEX matching' do
      it 'matches standard checkbox format' do
        expect('- [ ] Task').to match(MarkdownChecklistParser::Task::BASE_REGEX)
      end

      it 'matches checked checkbox' do
        expect('- [x] Task').to match(MarkdownChecklistParser::Task::BASE_REGEX)
      end

      it 'matches with extra spaces' do
        expect('-   [x]   Task').to match(MarkdownChecklistParser::Task::BASE_REGEX)
      end

      it 'does not match without checkbox' do
        expect('- Task without checkbox').not_to match(MarkdownChecklistParser::Task::BASE_REGEX)
      end
    end

    context 'real-world examples' do
      it 'parses GitHub-style PR checklist item' do
        task = MarkdownChecklistParser::Task.new('- [x] Tests passing <!-- Optional -->')

        expect(task.title).to eq('Tests passing')
        expect(task.checked).to be true
        expect(task.optional).to be true
      end

      it 'parses deployment option' do
        task = MarkdownChecklistParser::Task.new('- [ ] Deploy to production <!-- Choice#environment -->')

        expect(task.title).to eq('Deploy to production')
        expect(task.choosable).to be true
        expect(task.choice_id).to eq('environment')
      end

      it 'parses feature flag selection' do
        task = MarkdownChecklistParser::Task.new('- [x] Feature A <!-- Choice#features, multiple -->')

        expect(task.title).to eq('Feature A')
        expect(task.checked).to be true
        expect(task.choosable).to be true
        expect(task.multiple_choosable).to be true
      end
    end
  end
end
