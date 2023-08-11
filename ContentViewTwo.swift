import SwiftUI
import Speech
import NaturalLanguage
import AVFoundation

struct ContentView: View {
    @State private var sentiment: String = "Neutral"
    @State private var recognizedText: String = ""
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer()
    private let request = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask: SFSpeechRecognitionTask?

    var body: some View {
        VStack {
            Text("Detected Sentiment: \(sentiment)")
                .font(.headline)
                .padding()
            VideoPlayerView(videoName: sentiment)
            Text(recognizedText)
        }
        .onAppear(perform: startListening)
    }

    func startListening() {
        guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
            print("Speech recognition is not available on this device!")
            return
        }

        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [request] buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("There was an error starting the audio engine:", error)
            return
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self?.recognizedText = result.bestTranscription.formattedString
                    self?.sentiment = self?.analyzeSentiment(text: self?.recognizedText ?? "")
                }
            } else if let error = error {
                print("There was an error recognizing the speech:", error)
            }
        }


    }



    func analyzeSentiment(text: String) -> String {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text

        let (sentimentTag, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        let score = Double(sentimentTag?.rawValue ?? "0") ?? 0

        if score < -0.5 {
            return "Negative"
        } else if score > 0.5 {
            return "Positive"
        } else {
            return "Neutral"
        }
    }
}
