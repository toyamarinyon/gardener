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
    @fileType = GardenerFileType.css
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

  generateUniqueDomTree = (dom) ->
    node =
      tagname: dom.tagName || ''
      id: dom.id || ''
      classes: dom.className || ''
      children: []

    if dom.children.length > 0
      for child in dom.children
        node.children.push generateUniqueDomTree.call @, child

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
