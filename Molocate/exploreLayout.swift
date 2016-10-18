
import UIKit
protocol exploreLayoutDelegate {
  // 1. Method to ask the delegate for the height of the image
  func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath , withWidth:CGFloat) -> CGFloat
  // 2. Method to ask the delegate for the height of the annotation text
  func collectionView(_ collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat
  
}
var iseventhere = false
var eventcount = 0
class exploreLayoutAttributes:UICollectionViewLayoutAttributes {
  
  // 1. Custom attribute
  var photoHeight: CGFloat = 0.0
  
  // 2. Override copyWithZone to conform to NSCopying protocol
  override func copy(with zone: NSZone?) -> Any {
    let copy = super.copy(with: zone) as! exploreLayoutAttributes
    copy.photoHeight = photoHeight
    return copy
  }
  
  // 3. Override isEqual
  override func isEqual(_ object: Any?) -> Bool {
    if let attributtes = object as? exploreLayoutAttributes {
      if( attributtes.photoHeight == photoHeight  ) {
        return super.isEqual(object)
      }
    }
    return false
  }
}


class exploreLayout: UICollectionViewLayout {
  //1. explore Layout Delegate
  var delegate:exploreLayoutDelegate!
  var eventw = MolocateDevice.size.width
  var eventl = 9*(MolocateDevice.size.width/16)
  var scalew3 = (9*MolocateDevice.size.width-2)/209
  var scalew2 = (MolocateDevice.size.width-2)/8
  //2. Configurable properties
  var numberOfColumns = 2
    
  var cellPadding: CGFloat = 2.0
  var widths = [CGFloat]()
  var heights = [CGFloat]()
  //3. Array to keep a cache of attributes.
  fileprivate var cache = [exploreLayoutAttributes]()
  
  //4. Content height and size
  fileprivate var contentHeight:CGFloat  = 0.0
  fileprivate var contentWidth: CGFloat {
    let insets = collectionView!.contentInset
    return collectionView!.bounds.width - (insets.left + insets.right)
  }
  
  override class var layoutAttributesClass : AnyClass {
    return exploreLayoutAttributes.self
  }
  

  override func prepare() {
    // 1. Only calculate once
   // if cache.isEmpty {
        eventw = contentWidth
        eventl = 9*(contentWidth/16)
        scalew3 = ((9*contentWidth)-1)/209
        scalew2 = (contentWidth-1)/8
      let columnWidth = contentWidth / CGFloat(numberOfColumns)
      _ = [CGFloat]()
      var column = 0
      var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
      
      // 3. Iterates through the list of items in the first section
      for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
        
        let indexPath = IndexPath(item: item, section: 0)
        
        // 4. Asks the delegate for the height of the picture and the annotation and calculates the cell frame.
        var width = columnWidth - cellPadding*2
//        let photoHeight = delegate.collectionView(collectionView!, heightForPhotoAtIndexPath: indexPath , withWidth:width)
//        let annotationHeight = delegate.collectionView(collectionView!, heightForAnnotationAtIndexPath: indexPath, withWidth: width)
        
        var height = cellPadding + width + cellPadding
        var rest = indexPath.row % (10+eventcount)
        let part = CGFloat(indexPath.row/(10+eventcount))
        var contentLong = 2*(16*scalew3+3*scalew2+2*cellPadding)
        if part == 1  {
            if iseventhere {
            eventcount = 0
            contentLong = contentLong + contentWidth*9/16 + cellPadding
            rest = (indexPath.row-11) % 10
            } else {
            contentLong = 2*(16*scalew3+3*scalew2+2*cellPadding)
            }
        }

        var xoffset = CGFloat(0.0)
        var yoffset = CGFloat(0.0) + (contentLong)*part

        

        switch rest {

        case 0+eventcount:
            height = 16*scalew3
            width = 9*scalew3
            widths.append(width)
            heights.append(height)
        case 1+eventcount:
            height = 8*scalew3-1
            width = 16*height/9
            xoffset = widths[0] + cellPadding
            widths.append(width)
            heights.append(height)
        case 2+eventcount:
            height = 8*scalew3-1
            width = 16*height/9
            xoffset = widths[0] + cellPadding
            yoffset = heights[1] + cellPadding + (contentLong+cellPadding)*part
            widths.append(width)
            heights.append(height)
        case 3+eventcount:
            height = 3*scalew2
            width = 4*scalew2
            yoffset = heights[0] + cellPadding + (contentLong+cellPadding)*part
            widths.append(width)
            heights.append(height)
        case 4+eventcount:
            height = 3*scalew2
            width = 4*scalew2
            yoffset = heights[0] + cellPadding + (contentLong+cellPadding)*part
            xoffset = widths[3]+cellPadding
            widths.append(width)
            heights.append(height)
        case 5+eventcount:
            height = 8*scalew3-1
            width = 16*height/9
            yoffset = heights[0] + heights[3] + 2*cellPadding + (contentLong+cellPadding)*part
            widths.append(width)
            heights.append(height)
        case 6+eventcount:
            height = 8*scalew3-1
            width = 16*height/9
            yoffset = heights[0] + heights[3] + heights[5] + 3*cellPadding + (contentLong+cellPadding)*part
            widths.append(width)
            heights.append(height)
        case 7+eventcount:
            height = 16*scalew3
            width = 9*scalew3
            xoffset = widths[1]+cellPadding
            yoffset = heights[0] + heights[3] + 2*cellPadding + (contentLong+cellPadding)*part
            widths.append(width)
            heights.append(height)
        case 8+eventcount:
            height = 3*scalew2
            width = 4*scalew2
            yoffset = heights[0] + heights[3] + 3*cellPadding + heights[7] + (contentLong+cellPadding)*part
            widths.append(width)
            heights.append(height)
        case 9+eventcount:
            height = 3*scalew2
            width = 4*scalew2
            xoffset = widths[3]+cellPadding
            yoffset = heights[0] + heights[3] + 3*cellPadding + heights[7] + (contentLong+cellPadding)*part
            widths.append(width)
            heights.append(height)
        default:
            height = eventl
            width = eventw
            yoffset = yoffset - CGFloat(eventcount)*(eventl+cellPadding)
            
        }

        yoffset = yoffset + CGFloat(eventcount)*(eventl+cellPadding)
        
        let frame = CGRect(x: xoffset, y: yoffset, width: width, height: height)

        let insetFrame = frame.insetBy(dx: 0, dy: 0)
        
        // 5. Creates an UICollectionViewLayoutItem with the frame and add it to the cache
        let attributes = exploreLayoutAttributes(forCellWith: indexPath)
        attributes.photoHeight = height
        attributes.frame = insetFrame
        cache.append(attributes)
        
        // 6. Updates the collection view content height
        contentHeight = max(contentHeight, frame.maxY)
        yOffset[column] = yOffset[column] + height + cellPadding
        
        if column >= (numberOfColumns - 1) {
           column=0
        }else{
           column = column+1
        }
      }
    //}
  }
  
  override var collectionViewContentSize : CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    // Loop through the cache and look for items in the rect
    for attributes  in cache {
      if attributes.frame.intersects(rect ) {
        layoutAttributes.append(attributes)
      }
    }
    return layoutAttributes
  }
}


