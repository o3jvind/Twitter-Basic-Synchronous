#tag Module
Protected Module TwitterTools
	#tag Method, Flags = &h0
		Function twGetProfileImage(URL As  String) As Picture
		  //Get the name of the image
		  Dim ImageNameParts(-1) As String = Split(URL, "/")
		  Dim ImageName As String = ImageNameParts(ImageNameParts.Ubound)
		  
		  //Get the extension because we need to know if it is a jpeg or png image
		  Dim ExtensionParts(-1) As String = Split(ImageName, ".")
		  Dim Extension As String = ExtensionParts(ExtensionParts.Ubound)
		  
		  //Check if the picture has allready been downloaded
		  If twProfileImages.Ubound > - 1 Then
		    
		    for i As Integer = 0 to twProfileImages.Ubound
		      if twProfileImages(i).twProfileImagePath = URL Then
		        Dim ImageFile As FolderItem
		        ImageFile = SpecialFolder.Temporary.Child(ImageName)
		        
		        If ImageFile <> Nil Then
		          Dim p As Picture
		          p = Picture.Open(ImageFile)
		          Return p
		        End If
		        Exit Function
		      End if
		    Next
		  End if
		  
		  //Else download it and add it to the twProfileImages array and return the picture
		  
		  Dim socket As New twSocket
		  socket.Yield = True
		  Dim data As String = socket.Get(URL, 5)
		  
		  If socket.HTTPStatusCode = 200 Then
		    
		    Dim p As Picture = Picture.FromData(data)
		    
		    If p <> Nil Then
		      
		      //Save as PNG
		      If Extension = "png" Then 
		        If p.IsExportFormatSupported(Picture.FormatPNG) Then
		          //Save the file
		          Dim f As  FolderItem
		          f = SpecialFolder.Temporary.Child(ImageName)
		          p.Save(f, Picture.SaveAsPNG)
		        End if
		      else
		        //Save as jpg
		        If p.IsExportFormatSupported(Picture.FormatJPEG) Then
		          //Save the file
		          Dim f As  FolderItem
		          f = SpecialFolder.Temporary.Child(ImageName)
		          p.Save(f, Picture.SaveAsJPEG)
		        End if
		        //And add it to twProfileImages()
		        Dim newImage As New twProfileImage
		        newImage.twProfileImagePath = URL
		        twProfileImages.Append(newImage)
		        
		      End if
		      Return p
		    Else
		      MsgBox("Could not get picture")
		    End If
		    
		  Else 
		    MsgBox("HTTP Status: " + Str(socket.HTTPStatusCode))
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function twGetToken(ck As String, cs As String) As String
		  //https://dev.twitter.com/oauth/application-only
		  
		  Dim twTokenSocket As New twSocket
		  Dim s As String
		  
		  s = ck + ":" + cs 
		  s = EncodeBase64(s, 0)
		  
		  twTokenSocket.SetRequestHeader("Content-Type:", "application/x-www-form-urlencoded;charset=UTF-8")
		  twTokenSocket.SetRequestHeader("Authorization:", "Basic " + s)
		  twTokenSocket.SetRequestContent("grant_type=client_credentials", "application/x-www-form-urlencoded")
		  
		  Dim Response As String
		  Response = twTokenSocket.Post("https://api.twitter.com/oauth2/token", 10)
		  
		  
		  Try
		    
		    Dim js As New JSONItem(Response)
		    Return js.Value("access_token")
		    
		  Catch JSONException
		    If Response = "" Then
		      MsgBox("No Response")
		    Else
		      Msgbox(Response)
		    End if
		  End Try
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub twGetTweets(twQ As  String, twCount As String)
		  
		  Dim twTweetsSocket As New twSocket
		  
		  
		  Dim s As String
		  Dim t As  Text
		  
		  twTweetsSocket.SetRequestHeader("Authorization:", "Bearer " + twAccessToken)
		  s = twTweetsSocket.Get("https://api.twitter.com/1.1/search/tweets.json?q="+ EncodeURLComponent(twQ) + "&count=" + twCount, 30)
		  
		  If s = "" Then
		    MsgBox("No Response!")
		    Return
		  End if
		  
		  s = DefineEncoding(s, Encodings.UTF8)
		  'Dim c As New Clipboard
		  'c.text = s
		  t = s.ToText
		  
		  Try
		    Dim js As Xojo.Core.Dictionary = Xojo.Data.ParseJSON(t)
		    Dim results() As Auto = js.Value("statuses")
		    Dim n As  Xojo.Core.Dictionary
		    
		    ReDim twTweets(-1)
		    Dim twTweetsNumber As Integer
		    
		    twTweetsNumber = results.Ubound
		    Window1.NumberField.Text = Str(twTweetsNumber + 1)
		    
		    For i As Integer = 0 to twTweetsNumber
		      Dim NewTweet As New twTweetObject
		      n = results(i)
		      If n.HasKey("created_at") Then
		        NewTweet.TwDate =n.Value("created_at")
		      End if
		      
		      if n.HasKey("user") Then
		        Dim user As xojo.Core.Dictionary
		        user = n.Value("user")
		        if user.HasKey("name") Then
		          NewTweet.TwUserName = user.Value("name")
		        End if
		        
		        if user.HasKey("profile_image_url_https") Then
		          NewTweet.twProfileImagePath =  user.Value("profile_image_url_https")
		          NewTweet.twProfileImage = TwitterTools.twGetProfileImage(user.Value("profile_image_url_https"))
		        End if
		        
		      End If
		      
		      If n.HasKey("text") Then
		        NewTweet.twMessage = n.Value("text")
		      End if
		      
		      If n.HasKey("id_str") Then
		        NewTweet.twId = n.Value("id_str")
		      End if
		      
		      twTweets.Append(NewTweet)
		      twCounter = i
		    Next
		    
		  Catch JSONException
		    Msgbox(t)
		    
		  End Try
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		twAccessToken As String
	#tag EndProperty

	#tag Property, Flags = &h0
		twConsumerKey As String
	#tag EndProperty

	#tag Property, Flags = &h0
		twConsumerSecret As String
	#tag EndProperty

	#tag Property, Flags = &h0
		twCounter As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		twProfileImages() As twProfileImage
	#tag EndProperty

	#tag Property, Flags = &h0
		twTweets() As twTweetObject
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="twAccessToken"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="twConsumerKey"
			Group="Behavior"
			InitialValue="zvtlEof0yvz1koj1Ld7X7yXpA"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="twConsumerSecret"
			Group="Behavior"
			InitialValue="NpGzOfkvPB77d5GGk1oBGf4Y4gC8we7j5GUcLfHxRHf3YJSICm"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="twCounter"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
