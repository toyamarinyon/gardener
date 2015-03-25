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


testArray = [
  '#test':[
    '.ul1':[
      '.span1':[
      ],
      '.span2':[
      ]
    ],
    '.ul2':[
    ],
  ]
]

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

  convert: (domTree) ->
    @selectorStack = []
    @converted = ''
    @nestLevel = 1
    uniqueDomTree = generateUniqueDomTree.call @, domTree
    execConvert.call @, uniqueDomTree
    return @converted

  generateDom = (dom) ->
    node =
      tagname: dom.tagName || ''
      id: dom.id || ''
      classes: dom.className || ''
      children: []

  generateUniqueDomTree = (dom) ->
    node = generateDom.call @, dom

    nodeToStr = (node) ->
      string = ''
      string += node.tagname unless node.tagname is ''
      string += '#'+node.id unless node.id is ''
      string += '.'+node.classes unless node.classes is ''
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
          console.dir cacheChildren[cacheHitIndex].children
          # cacheChildren[cacheHitIndex].children.push child.children if child.children.length > 0
          # console.dir cacheChildren[cacheHitIndex].children.length
      for cacheChild in cacheChildren
        node.children.push generateUniqueDomTree.call @, cacheChild


    return node


  execConvert = (dom) ->
    selectorString = ''
    selectorString += "#"+dom.id if dom.id
    selectorString += "."+dom.classes if dom.classes

    postSelector.call @, selectorString

    if dom.children.length > 0
      preChildren.call @, selectorString
      for child in dom.children
        preChild.call @
        execConvert.call @, child
      postChildren.call @
    else
      postChild.call @
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
