describe Fastlane::Actions::MakeReleaseAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The release plugin is working!")

      Fastlane::Actions::MakeReleaseAction.run(nil)
    end
  end
end
