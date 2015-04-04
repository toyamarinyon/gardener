GardenerNestRule =
  noNest: 0
  children: 1
  child: 2

GardenerFileType =
  css: 0
  scss: 1
  less: 2
  sass: 3

GardenerControlCharacter =
  twoSpace: '  '
  lineBreak: '\n'

class Gardener

  constructor: (args) ->
    @nestRule = GardenerNestRule.noNest
    if args? and args.nestRule?
      @nestRule = args.nestRule
    @fileType = GardenerFileType.scss
    if args? and args.nestRule?
      @fileType = args.fileType
    @selectorStack = []
    @converted
    @nestLevel = 1
    @dummyFlg = true

  convert: (domTree) ->
    @selectorStack = []
    @converted = ''
    @nestLevel = 1
    domObjects = domToObjects.call @, domTree
    uniqueDomTree = generateUniqueDomTree.call @, domObjects
    execConvert.call @, uniqueDomTree
    return @converted

  generateDom = (dom) ->
    node =
      tagName: dom.tagName || ''
      id: dom.id || ''
      className: dom.className || ''
      children: []

  domToObjects = (dom) ->
    object = generateDom.call @, dom
    if dom.hasChildNodes()
      for child in dom.childNodes
        if child.nodeName is '#text'
          continue
        object.children.push domToObjects.call @, child
    return object

  generateUniqueDomTree = (dom) ->
    node = generateDom.call @, dom

    nodeToStr = (node) ->
      string = ''
      string += node.tagName unless node.tagName is ''
      string += '#'+node.id unless node.id is ''
      string += '.'+node.className unless node.className is ''
      return string

    if dom.children.length > 0
      cache = []
      cacheChildren = []
      for child in dom.children
        _dom = generateDom.call @, child
        _domToStr = nodeToStr _dom
        cacheHitIndex = cache.indexOf _domToStr
        if cacheHitIndex < 0
          cache.push _domToStr
          cacheChildren.push child
        else
          cacheChildren[cacheHitIndex].children = cacheChildren[cacheHitIndex].children.concat child.children if child.children.length > 0
      for cacheChild in cacheChildren
        node.children.push generateUniqueDomTree.call @, cacheChild
    return node


  execConvert = (dom) ->
    domToStr = (dom) ->
      string = ''
      string += "#"+dom.id if dom.id
      string += "."+dom.className if dom.className
      return string

    selectorString = domToStr dom
    postSelector.call @, selectorString if selectorString unless ''

    if dom.children.length > 0
      preChildren.call @, selectorString if selectorString unless ''
      for child in dom.children
        preChild.call @ if domToStr child unless ''
        execConvert.call @, child
      postChildren.call @ if selectorString unless ''
    else
      postChild.call @ if selectorString unless ''
      @prevConvertString = ''

  postSelector = (selectorString) ->
    switch @fileType
      when GardenerFileType.css
        @selectorStack.push selectorString
      when GardenerFileType.less,GardenerFileType.scss,GardenerFileType.sass
        @converted += selectorString

  preChildren = ->
      switch @fileType
        when GardenerFileType.less,GardenerFileType.scss
          @nestLevel++
          @converted += " {"+
                        GardenerControlCharacter.lineBreak
        when GardenerFileType.sass
          @nestLevel++
          @converted += GardenerControlCharacter.lineBreak

  postChildren = ->
    switch @fileType
      when GardenerFileType.less,GardenerFileType.scss
        @nestLevel--
        @converted += Array(@nestLevel).join(GardenerControlCharacter.twoSpace)+
                      "}"+
                      GardenerControlCharacter.lineBreak
      when GardenerFileType.less,GardenerFileType.sass
        @nestLevel--

  preChild = ->
    switch @fileType
      when GardenerFileType.css then ''
      when GardenerFileType.less,GardenerFileType.scss,GardenerFileType.sass
        @converted += Array(@nestLevel).join(GardenerControlCharacter.twoSpace)

  postChild = ->
    switch @fileType
      when GardenerFileType.css
        @converted += @selectorStack.join(' ') + 
                      ' {'+
                      GardenerControlCharacter.lineBreak +
                      '}'+
                      GardenerControlCharacter.lineBreak
        @selectorStack.pop()
      when GardenerFileType.less,GardenerFileType.scss
        @converted += " {"+
                      GardenerControlCharacter.lineBreak+
                      Array(@nestLevel).join(GardenerControlCharacter.twoSpace)+
                      "}"+
                      GardenerControlCharacter.lineBreak
      when GardenerFileType.sass
        @converted += GardenerControlCharacter.lineBreak
