#tag Module
Protected Module TwitterTools
	#tag Method, Flags = &h0
		Function twGetProfileImage(URL As  String) As Picture
		  Dim socket As New twSocket
		  Dim data As String = socket.Get(URL, 5)
		  
		  If socket.HTTPStatusCode = 200 Then
		    
		    Dim p As Picture = Picture.FromData(data)
		    
		    If p <> Nil Then
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
		    
		    For i As Integer = 0 to results.Ubound
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
	#tag EndViewBehavior
End Module
#tag EndModule
