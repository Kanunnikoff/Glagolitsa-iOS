//
//  LinkPreviewView.swift
//  Yat
//
//  Created by Kanunnikov Dmitriy  on 22.11.2025.
//

import SwiftUI
import LinkPresentation

struct LinkPreviewView {

    let url: URL
    let cornerRadius: CGFloat
}

#if os(macOS)
extension LinkPreviewView: NSViewRepresentable {

    func makeNSView(context: Context) -> LPLinkView {
        makeLinkView()
    }

    func sizeThatFits(_ proposal: ProposedViewSize, nsView: LPLinkView, context: Context) -> CGSize? {
        preferredSize(for: nsView, proposal: proposal)
    }

    func updateNSView(_ nsView: LPLinkView, context: Context) {
        applyCornerRadius(to: nsView)
    }
}
#else
extension LinkPreviewView: UIViewRepresentable {

    func makeUIView(context: Context) -> LPLinkView {
        makeLinkView()
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: LPLinkView, context: Context) -> CGSize? {
        preferredSize(for: uiView, proposal: proposal)
    }

    func updateUIView(_ uiView: LPLinkView, context: Context) {
        applyCornerRadius(to: uiView)
    }
}
#endif

private extension LinkPreviewView {

    enum PreviewData {
        static let cornerRadius: CGFloat = 50
        static let urlString = "https://www.vedomosti.ru/politics/news/2025/11/22/1157219-zapadnie-lideri"
    }

    func makeLinkView() -> LPLinkView {
        let linkView = LPLinkView(url: url)

        applyCornerRadius(to: linkView)
        loadMetadata(for: linkView)

        return linkView
    }

    func loadMetadata(for linkView: LPLinkView) {
        let metadataProvider = LPMetadataProvider()

        metadataProvider.startFetchingMetadata(for: url) { metadata, _ in
            guard let metadata else {
                return
            }

            DispatchQueue.main.async {
                linkView.metadata = metadata
                updateLayout(for: linkView)
                applyCornerRadius(to: linkView)
            }
        }
    }

    func updateLayout(for linkView: LPLinkView) {
#if !os(macOS)
        linkView.sizeToFit()
#else
        linkView.needsLayout = true
#endif
    }

    func preferredSize(for linkView: LPLinkView, proposal: ProposedViewSize) -> CGSize? {
#if os(macOS)
        let fittingSize = linkView.fittingSize
        let width = proposal.width ?? fittingSize.width
        let height = fittingSize.height > 0 ? fittingSize.height : linkView.intrinsicContentSize.height

        return CGSize(width: width, height: height)
#else
        let width = proposal.width ?? linkView.intrinsicContentSize.width
        let bestFit = linkView.sizeThatFits(
            CGSize(width: width, height: .greatestFiniteMagnitude)
        )

        return CGSize(width: width, height: bestFit.height)
#endif
    }

    func applyCornerRadius(to linkView: LPLinkView) {
#if os(macOS)
        linkView.wantsLayer = true
        linkView.layer?.cornerRadius = cornerRadius
        linkView.layer?.masksToBounds = true
#else
        linkView.layer.cornerRadius = cornerRadius
        linkView.layer.masksToBounds = true
#endif
    }
}

#Preview {
    if let url = URL(string: LinkPreviewView.PreviewData.urlString) {
        LinkPreviewView(
            url: url,
            cornerRadius: LinkPreviewView.PreviewData.cornerRadius
        )
    }
}
