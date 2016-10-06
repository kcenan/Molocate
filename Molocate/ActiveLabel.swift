//
//  ActiveLabel.swift
//  ActiveLabel
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import Foundation
import UIKit

public protocol ActiveLabelDelegate: class {
    func didSelectText(_ text: String, type: ActiveType)
}

@IBDesignable open class ActiveLabel: UILabel {
    
    // MARK: - public properties
    open weak var delegate: ActiveLabelDelegate?
    
    @IBInspectable open var mentionColor: UIColor = .blue() {
        didSet { updateTextStorage(parseText: false) }
    }
    @IBInspectable open var mentionSelectedColor: UIColor? {
        didSet { updateTextStorage(parseText: false) }
    }
    @IBInspectable open var hashtagColor: UIColor = .blue() {
        didSet { updateTextStorage(parseText: false) }
    }
    @IBInspectable open var hashtagSelectedColor: UIColor? {
        didSet { updateTextStorage(parseText: false) }
    }
    @IBInspectable open var URLColor: UIColor = .blue() {
        didSet { updateTextStorage(parseText: false) }
    }
    @IBInspectable open var URLSelectedColor: UIColor? {
        didSet { updateTextStorage(parseText: false) }
    }
    @IBInspectable open var lineSpacing: Float = 0 {
        didSet { updateTextStorage(parseText: false) }
    }
    
    // MARK: - public methods
    open func handleMentionTap(_ handler: @escaping (String) -> ()) {
        mentionTapHandler = handler
    }
    
    open func handleHashtagTap(_ handler: @escaping (String) -> ()) {
        hashtagTapHandler = handler
    }
    
    open func handleURLTap(_ handler: @escaping (URL) -> ()) {
        urlTapHandler = handler
    }
    
    open func filterMention(_ predicate: @escaping (String) -> Bool) {
        mentionFilterPredicate = predicate
        updateTextStorage()
    }
    
    open func filterHashtag(_ predicate: @escaping (String) -> Bool) {
        hashtagFilterPredicate = predicate
        updateTextStorage()
    }
    
    // MARK: - override UILabel properties
    override open var text: String? {
        didSet { updateTextStorage() }
    }
    
    override open var attributedText: NSAttributedString? {
        didSet { updateTextStorage() }
    }
    
    override open var font: UIFont! {
        didSet { updateTextStorage(parseText: false) }
    }
    
    override open var textColor: UIColor! {
        didSet { updateTextStorage(parseText: false) }
    }
    
    override open var textAlignment: NSTextAlignment {
        didSet { updateTextStorage(parseText: false)}
    }
    
    open override var numberOfLines: Int {
        didSet { textContainer.maximumNumberOfLines = numberOfLines }
    }
    
    open override var lineBreakMode: NSLineBreakMode {
        didSet { textContainer.lineBreakMode = lineBreakMode }
    }
    
    // MARK: - init functions
    override public init(frame: CGRect) {
        super.init(frame: frame)
        _customizing = false
        setupLabel()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _customizing = false
        setupLabel()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        updateTextStorage()
    }
    
    open override func drawText(in rect: CGRect) {
        let range = NSRange(location: 0, length: textStorage.length)
        
        textContainer.size = rect.size
        let newOrigin = textOrigin(inRect: rect)
        
        layoutManager.drawBackground(forGlyphRange: range, at: newOrigin)
        layoutManager.drawGlyphs(forGlyphRange: range, at: newOrigin)
    }
    
    
    // MARK: - customzation
    open func customize(_ block: (_ label: ActiveLabel) -> ()) -> ActiveLabel{
        _customizing = true
        block(self)
        _customizing = false
        updateTextStorage()
        return self
    }
    
    // MARK: - Auto layout
    open override var intrinsicContentSize : CGSize {
        let superSize = super.intrinsicContentSize
        textContainer.size = CGSize(width: superSize.width, height: CGFloat.greatestFiniteMagnitude)
        let size = layoutManager.usedRect(for: textContainer)
        return CGSize(width: size.width, height: ceil(size.height))
    }
    
    // MARK: - touch events
    func onTouch(_ touch: UITouch) -> Bool {
        let location = touch.location(in: self)
        var avoidSuperCall = false
        
        switch touch.phase {
        case .began, .moved:
            if let element = elementAtLocation(location) {
                if element.range.location != selectedElement?.range.location || element.range.length != selectedElement?.range.length {
                    updateAttributesWhenSelected(false)
                    selectedElement = element
                    updateAttributesWhenSelected(true)
                }
                avoidSuperCall = true
            } else {
                updateAttributesWhenSelected(false)
                selectedElement = nil
            }
        case .ended:
            guard let selectedElement = selectedElement else { return avoidSuperCall }
            
            switch selectedElement.element {
            case .mention(let userHandle): didTapMention(userHandle)
            case .hashtag(let hashtag): didTapHashtag(hashtag)
            case .url(let url): didTapStringURL(url)
            case .none: ()
            }
            
            let when = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.updateAttributesWhenSelected(false)
                self.selectedElement = nil
            }
            avoidSuperCall = true
        case .cancelled:
            updateAttributesWhenSelected(false)
            selectedElement = nil
        case .stationary:
            break
        }
        
        return avoidSuperCall
    }
    
    // MARK: - private properties
    fileprivate var _customizing: Bool = true
    
    fileprivate var mentionTapHandler: ((String) -> ())?
    fileprivate var hashtagTapHandler: ((String) -> ())?
    fileprivate var urlTapHandler: ((URL) -> ())?
    
    fileprivate var mentionFilterPredicate: ((String) -> Bool)?
    fileprivate var hashtagFilterPredicate: ((String) -> Bool)?
    
    fileprivate var selectedElement: (range: NSRange, element: ActiveElement)?
    fileprivate var heightCorrection: CGFloat = 0
    fileprivate lazy var textStorage = NSTextStorage()
    fileprivate lazy var layoutManager = NSLayoutManager()
    fileprivate lazy var textContainer = NSTextContainer()
    internal lazy var activeElements: [ActiveType: [(range: NSRange, element: ActiveElement)]] = [
        .mention: [],
        .hashtag: [],
        .url: [],
        ]
    
    // MARK: - helper functions
    fileprivate func setupLabel() {
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines
        isUserInteractionEnabled = true
    }
    
    fileprivate func updateTextStorage(parseText: Bool = true) {
        if _customizing { return }
        // clean up previous active elements
        guard let attributedText = attributedText , attributedText.length > 0 else {
            clearActiveElements()
            textStorage.setAttributedString(NSAttributedString())
            setNeedsDisplay()
            return
        }
        
        let mutAttrString = addLineBreak(attributedText)
        
        if parseText {
            clearActiveElements()
            parseTextAndExtractActiveElements(mutAttrString)
        }
        
        self.addLinkAttribute(mutAttrString)
        self.textStorage.setAttributedString(mutAttrString)
        self.setNeedsDisplay()
    }
    
    fileprivate func clearActiveElements() {
        selectedElement = nil
        for (type, _) in activeElements {
            activeElements[type]?.removeAll()
        }
    }
    
    fileprivate func textOrigin(inRect rect: CGRect) -> CGPoint {
        let usedRect = layoutManager.usedRect(for: textContainer)
        heightCorrection = (rect.height - usedRect.height)/2
        let glyphOriginY = heightCorrection > 0 ? rect.origin.y + heightCorrection : rect.origin.y
        return CGPoint(x: rect.origin.x, y: glyphOriginY)
    }
    
    /// add link attribute
    fileprivate func addLinkAttribute(_ mutAttrString: NSMutableAttributedString) {
        var range = NSRange(location: 0, length: 0)
        var attributes = mutAttrString.attributes(at: 0, effectiveRange: &range)
        
        attributes[NSFontAttributeName] = font!
        attributes[NSForegroundColorAttributeName] = textColor
        mutAttrString.addAttributes(attributes, range: range)
        
        attributes[NSForegroundColorAttributeName] = mentionColor
        
        for (type, elements) in activeElements {
            
            switch type {
            case .mention: attributes[NSForegroundColorAttributeName] = mentionColor
            case .hashtag: attributes[NSForegroundColorAttributeName] = hashtagColor
            case .url: attributes[NSForegroundColorAttributeName] = URLColor
            case .none: ()
            }
            
            for element in elements {
                mutAttrString.setAttributes(attributes, range: element.range)
            }
        }
    }
    
    /// use regex check all link ranges
    fileprivate func parseTextAndExtractActiveElements(_ attrString: NSAttributedString) {
        let textString = attrString.string
        let textLength = textString.utf16.count
        let textRange = NSRange(location: 0, length: textLength)
        
        //URLS
        let urlElements = ActiveBuilder.createURLElements(fromText: textString, range: textRange)
        activeElements[.url]?.append(contentsOf: urlElements)
        
        //HASHTAGS
        let hashtagElements = ActiveBuilder.createHashtagElements(fromText: textString, range: textRange, filterPredicate: hashtagFilterPredicate)
        activeElements[.hashtag]?.append(contentsOf: hashtagElements)
        
        //MENTIONS
        let mentionElements = ActiveBuilder.createMentionElements(fromText: textString, range: textRange, filterPredicate: mentionFilterPredicate)
        activeElements[.mention]?.append(contentsOf: mentionElements)
    }
    
    
    /// add line break mode
    fileprivate func addLineBreak(_ attrString: NSAttributedString) -> NSMutableAttributedString {
        let mutAttrString = NSMutableAttributedString(attributedString: attrString)
        
        var range = NSRange(location: 0, length: 0)
        var attributes = mutAttrString.attributes(at: 0, effectiveRange: &range)
        
        let paragraphStyle = attributes[NSParagraphStyleAttributeName] as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineSpacing = CGFloat(lineSpacing)
        
        attributes[NSParagraphStyleAttributeName] = paragraphStyle
        mutAttrString.setAttributes(attributes, range: range)
        
        return mutAttrString
    }
    
    fileprivate func updateAttributesWhenSelected(_ isSelected: Bool) {
        guard let selectedElement = selectedElement else {
            return
        }
        
        var attributes = textStorage.attributes(at: 0, effectiveRange: nil)
        if isSelected {
            switch selectedElement.element {
            case .mention(_): attributes[NSForegroundColorAttributeName] = mentionSelectedColor ?? mentionColor
            case .hashtag(_): attributes[NSForegroundColorAttributeName] = hashtagSelectedColor ?? hashtagColor
            case .url(_): attributes[NSForegroundColorAttributeName] = URLSelectedColor ?? URLColor
            case .none: ()
            }
        } else {
            switch selectedElement.element {
            case .mention(_): attributes[NSForegroundColorAttributeName] = mentionColor
            case .hashtag(_): attributes[NSForegroundColorAttributeName] = hashtagColor
            case .url(_): attributes[NSForegroundColorAttributeName] = URLColor
            case .none: ()
            }
        }
        
        textStorage.addAttributes(attributes, range: selectedElement.range)
        
        setNeedsDisplay()
    }
    
    fileprivate func elementAtLocation(_ location: CGPoint) -> (range: NSRange, element: ActiveElement)? {
        guard textStorage.length > 0 else {
            return nil
        }
        
        var correctLocation = location
        correctLocation.y -= heightCorrection
        let boundingRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: 0, length: textStorage.length), in: textContainer)
        guard boundingRect.contains(correctLocation) else {
            return nil
        }
        
        let index = layoutManager.glyphIndex(for: correctLocation, in: textContainer)
        
        for element in activeElements.map({ $0.1 }).joined() {
            if index >= element.range.location && index <= element.range.location + element.range.length {
                return element
            }
        }
        
        return nil
    }
    
    
    //MARK: - Handle UI Responder touches
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch) { return }
        super.touchesBegan(touches, with: event)
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch) { return }
        super.touchesMoved(touches, with: event)
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        onTouch(touch)
        super.touchesCancelled(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch) { return }
        super.touchesEnded(touches, with: event)
    }
    
    //MARK: - ActiveLabel handler
    fileprivate func didTapMention(_ username: String) {
        guard let mentionHandler = mentionTapHandler else {
            delegate?.didSelectText(username, type: .mention)
            return
        }
        mentionHandler(username)
    }
    
    fileprivate func didTapHashtag(_ hashtag: String) {
        guard let hashtagHandler = hashtagTapHandler else {
            delegate?.didSelectText(hashtag, type: .hashtag)
            return
        }
        hashtagHandler(hashtag)
    }
    
    fileprivate func didTapStringURL(_ stringURL: String) {
        guard let urlHandler = urlTapHandler, let url = URL(string: stringURL) else {
            delegate?.didSelectText(stringURL, type: .url)
            return
        }
        urlHandler(url)
    }
}

extension ActiveLabel: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
