import UIKit
import GoogleMobileAds

final class NativeAdTableViewCell: UITableViewCell {
    private var nativeAdView: NativeAdView!
    private let headline = UILabel()
    private let body = UILabel()
    private let mediaView = MediaView()
    private let ctaButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupAdView()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAdView()
    }

    private func setupAdView() {
        backgroundColor = .clear
        selectionStyle = .none

        // container met afgeronde hoeken
        nativeAdView = NativeAdView(frame: .zero)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.backgroundColor = .secondarySystemBackground
        nativeAdView.layer.cornerRadius = 12
        nativeAdView.layer.masksToBounds = true

        contentView.addSubview(nativeAdView)
        NSLayoutConstraint.activate([
            nativeAdView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            nativeAdView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            nativeAdView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nativeAdView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        // Headline
        headline.font = UIFont.boldSystemFont(ofSize: 16)
        headline.numberOfLines = 2
        headline.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.headlineView = headline
        nativeAdView.addSubview(headline)

        // Body
        body.font = UIFont.systemFont(ofSize: 14)
        body.textColor = .secondaryLabel
        body.numberOfLines = 2
        body.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.bodyView = body
        nativeAdView.addSubview(body)

        // Media
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        mediaView.layer.cornerRadius = 8
        mediaView.clipsToBounds = true
        nativeAdView.mediaView = mediaView
        nativeAdView.addSubview(mediaView)

        // CTA button
        ctaButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        ctaButton.backgroundColor = .systemBlue
        ctaButton.tintColor = .white
        ctaButton.layer.cornerRadius = 6
        ctaButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.callToActionView = ctaButton
        nativeAdView.addSubview(ctaButton)

        // Layout
        NSLayoutConstraint.activate([
            headline.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 12),
            headline.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -12),
            headline.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 12),

            body.leadingAnchor.constraint(equalTo: headline.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: headline.trailingAnchor),
            body.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 4),

            mediaView.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 8),
            mediaView.leadingAnchor.constraint(equalTo: headline.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: headline.trailingAnchor),
            mediaView.heightAnchor.constraint(equalToConstant: 140),

            ctaButton.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: 10),
            ctaButton.leadingAnchor.constraint(equalTo: headline.leadingAnchor),
            ctaButton.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with nativeAd: NativeAd) {
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        nativeAdView.nativeAd = nativeAd
    }
}
