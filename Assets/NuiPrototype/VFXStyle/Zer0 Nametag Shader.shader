// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "!Zer0/CVRNametag"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_StartFade("Start Fade", Float) = 0.3
		_EndFade("End Fade", Float) = 1
		_Tex("Tex", 2D) = "white" {}
		_Distortion("Distortion", 2D) = "bump" {}
		_distortionstrength1("distortionstrength1", Float) = 0
		_Distortionbstrength2("Distortionbstrength2", Float) = 0
		_distortionstrength3("distortionstrength3", Float) = 0
		_Brightness("Brightness", Float) = 1.45
		_Color2("Color 2", Color) = (0,0,1,0)
		_Speed("Speed", Vector) = (1,0,0,0)
		_Color1("Color 1", Color) = (0,1,0,0)
		_Color0("Color 0", Color) = (1,0,0,0)
		_TextureSample2("Texture Sample 2", 2D) = "white" {}
		_ColRowSpeed("ColRowSpeed", Vector) = (9,8,10,0)
		_SquareCut("SquareCut", Vector) = (1,1,0,0)
		_AnimatedUVS("AnimatedUVS", Vector) = (1,1,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float eyeDepth;
		};

		uniform sampler2D _Tex;
		uniform float4 _Tex_ST;
		uniform sampler2D _Distortion;
		uniform float2 _Speed;
		uniform float4 _Distortion_ST;
		uniform float _distortionstrength1;
		uniform float4 _Color0;
		uniform float4 _Color1;
		uniform float _Distortionbstrength2;
		uniform float4 _Color2;
		uniform float _distortionstrength3;
		uniform float _Brightness;
		uniform sampler2D _TextureSample2;
		uniform float4 _AnimatedUVS;
		uniform float4 _ColRowSpeed;
		uniform float2 _SquareCut;
		uniform float _StartFade;
		uniform float _EndFade;
		uniform float _Cutoff = 0.5;


		int IsInMirror1_g5(  )
		{
			return unity_CameraProjection[2][0] != 0.f || unity_CameraProjection[2][1] != 0.f;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv0_Tex = i.uv_texcoord * _Tex_ST.xy + _Tex_ST.zw;
			float2 uv0_Distortion = i.uv_texcoord * _Distortion_ST.xy + _Distortion_ST.zw;
			float2 panner66 = ( 1.0 * _Time.y * _Speed + uv0_Distortion);
			float3 tex2DNode34 = UnpackNormal( tex2D( _Distortion, panner66 ) );
			float4 tex2DNode12 = tex2D( _Tex, ( float3( uv0_Tex ,  0.0 ) + ( tex2DNode34 * _distortionstrength1 ) ).xy );
			float4 tex2DNode50 = tex2D( _Tex, ( float3( uv0_Tex ,  0.0 ) + ( tex2DNode34 * _Distortionbstrength2 ) ).xy );
			float4 tex2DNode51 = tex2D( _Tex, ( float3( uv0_Tex ,  0.0 ) + ( tex2DNode34 * _distortionstrength3 ) ).xy );
			float2 appendResult94 = (float2(_AnimatedUVS.x , _AnimatedUVS.y));
			float2 appendResult95 = (float2(_AnimatedUVS.z , _AnimatedUVS.w));
			float2 uv_TexCoord84 = i.uv_texcoord * appendResult94 + appendResult95;
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles83 = _ColRowSpeed.x * _ColRowSpeed.y;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset83 = 1.0f / _ColRowSpeed.x;
			float fbrowsoffset83 = 1.0f / _ColRowSpeed.y;
			// Speed of animation
			float fbspeed83 = _Time.y * _ColRowSpeed.z;
			// UV Tiling (col and row offset)
			float2 fbtiling83 = float2(fbcolsoffset83, fbrowsoffset83);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex83 = round( fmod( fbspeed83 + 0.0, fbtotaltiles83) );
			fbcurrenttileindex83 += ( fbcurrenttileindex83 < 0) ? fbtotaltiles83 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox83 = round ( fmod ( fbcurrenttileindex83, _ColRowSpeed.x ) );
			// Multiply Offset X by coloffset
			float fboffsetx83 = fblinearindextox83 * fbcolsoffset83;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy83 = round( fmod( ( fbcurrenttileindex83 - fblinearindextox83 ) / _ColRowSpeed.x, _ColRowSpeed.y ) );
			// Reverse Y to get tiles from Top to Bottom
			fblinearindextoy83 = (int)(_ColRowSpeed.y-1) - fblinearindextoy83;
			// Multiply Offset Y by rowoffset
			float fboffsety83 = fblinearindextoy83 * fbrowsoffset83;
			// UV Offset
			float2 fboffset83 = float2(fboffsetx83, fboffsety83);
			// Flipbook UV
			half2 fbuv83 = uv_TexCoord84 * fbtiling83 + fboffset83;
			// *** END Flipbook UV Animation vars ***
			float4 tex2DNode89 = tex2D( _TextureSample2, fbuv83 );
			float2 appendResult10_g4 = (float2(_SquareCut.x , _SquareCut.y));
			float2 temp_output_11_0_g4 = ( abs( (uv_TexCoord84*2.0 + -1.0) ) - appendResult10_g4 );
			float2 break16_g4 = ( 1.0 - ( temp_output_11_0_g4 / fwidth( temp_output_11_0_g4 ) ) );
			float temp_output_88_0 = saturate( min( break16_g4.x , break16_g4.y ) );
			o.Emission = ( ( ( ( tex2DNode12.r * _Color0 ) + ( _Color1 * tex2DNode50.g ) + ( _Color2 * tex2DNode51.b ) ) * _Brightness ) + ( tex2DNode89.a * ( tex2DNode89 * temp_output_88_0 ) ) ).rgb;
			float temp_output_4_0 = ( _StartFade + _ProjectionParams.y );
			o.Alpha = saturate( ( ( ( i.eyeDepth + -temp_output_4_0 ) / ( _EndFade - temp_output_4_0 ) ) - 0.0 ) );
			float4 temp_cast_7 = (( ( tex2DNode12.a + tex2DNode50.a + tex2DNode51.a ) + ( tex2DNode89.a * temp_output_88_0 ) )).xxxx;
			float4 temp_cast_8 = (0.0).xxxx;
			int localIsInMirror1_g5 = IsInMirror1_g5();
			float4 lerpResult4_g5 = lerp( temp_cast_7 , temp_cast_8 , (float)localIsInMirror1_g5);
			clip( lerpResult4_g5.x - _Cutoff );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
291;373;2100;891;1369.531;-640.84;1;True;False
Node;AmplifyShaderEditor.Vector2Node;67;-3092.759,-12.0282;Inherit;False;Property;_Speed;Speed;10;0;Create;True;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;69;-3040.759,-291.0282;Inherit;False;0;34;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;66;-2763.759,-163.0282;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;1;-1274.067,621.6085;Inherit;False;297.1897;243;Correction for near plane clipping;1;2;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-2035.904,-81.36792;Inherit;False;Property;_distortionstrength1;distortionstrength1;5;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2025.759,136.9718;Inherit;False;Property;_Distortionbstrength2;Distortionbstrength2;6;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;34;-2544.904,-202.3679;Inherit;True;Property;_Distortion;Distortion;4;0;Create;True;0;0;False;0;False;-1;118878b7e2b1c304d9bb1ce6a2da79f5;d09a135a3bfb1bf439658ae34ffe5833;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;64;-2045.759,364.9718;Inherit;False;Property;_distortionstrength3;distortionstrength3;7;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;93;-1217.368,934.0421;Inherit;False;Property;_AnimatedUVS;AnimatedUVS;16;0;Create;True;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-1801.759,22.97182;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;33;-1845.904,-349.3679;Inherit;False;0;12;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;94;-1030.079,902.7972;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;95;-1027.079,1051.797;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1131.282,519.3884;Float;False;Property;_StartFade;Start Fade;1;0;Create;True;0;0;False;0;False;0.3;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-1811.904,-195.3679;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-1821.759,250.9718;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ProjectionParams;2;-1201.367,670.9084;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-1478.904,-276.3679;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-1544.759,191.9718;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;4;-919.89,539.8203;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;84;-863.8179,898.7323;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;87;-794.9717,1182.722;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-1563.759,40.9718;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector4Node;85;-817.7494,1017.344;Inherit;False;Property;_ColRowSpeed;ColRowSpeed;14;0;Create;True;0;0;False;0;False;9,8,10,0;9,8,10,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;51;-1301.416,243.5874;Inherit;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;False;0;False;-1;21b609cabb307de458346d83e322de59;35c5ee4ee83079b4ca89d029d125042d;True;0;False;white;Auto;False;Instance;12;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SurfaceDepthNode;6;-898.2993,334.9056;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;12;-1301.59,-459.6143;Inherit;True;Property;_Tex;Tex;3;0;Create;True;0;0;False;0;False;-1;a99649a3ac7df724eb781c969383e632;35c5ee4ee83079b4ca89d029d125042d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;50;-1304.316,-105.0126;Inherit;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;False;0;False;-1;21b609cabb307de458346d83e322de59;35c5ee4ee83079b4ca89d029d125042d;True;0;False;white;Auto;False;Instance;12;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;83;-594.1703,1020.646;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ColorNode;57;-1207.759,-625.0282;Inherit;False;Property;_Color0;Color 0;12;0;Create;True;0;0;False;0;False;1,0,0,0;0,0.7222755,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;25;-664.3907,581.5857;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;7;-771.0046,414.1397;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;59;-1215.759,80.9718;Inherit;False;Property;_Color2;Color 2;9;0;Create;True;0;0;False;0;False;0,0,1,0;1,0.9721711,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;58;-1216.759,-270.0282;Inherit;False;Property;_Color1;Color 1;11;0;Create;True;0;0;False;0;False;0,1,0,0;1,0,0.9847546,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-787.9194,483.7932;Float;False;Property;_EndFade;End Fade;2;0;Create;True;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;91;-534.5319,1314.421;Inherit;False;Property;_SquareCut;SquareCut;15;0;Create;True;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-598.3198,362.3936;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-679.7585,-463.0282;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;88;-291.8942,1240.762;Inherit;True;Rectangle;-1;;4;6b23e0c975270fb4084c354b2c83366a;0;3;1;FLOAT2;0,0;False;2;FLOAT;0.5;False;3;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;9;-616.6193,450.8931;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;89;-297.3466,956.3555;Inherit;True;Property;_TextureSample2;Texture Sample 2;13;0;Create;True;0;0;False;0;False;-1;bf9447e9905e65b47a0af5e92186167e;bf9447e9905e65b47a0af5e92186167e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-849.7585,-217.0282;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-900.7585,29.9718;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;80;-404.759,-304.0282;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;147.4681,1051.421;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;229.4686,714.84;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;10;-453.5193,391.5932;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;79;-521.3667,151.4529;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-350.9041,-61.3679;Inherit;False;Property;_Brightness;Brightness;8;0;Create;True;0;0;False;0;False;1.45;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;368.4681,983.4206;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;96;-115.5014,109.1507;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-120.9041,-131.3679;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;11;-324.3834,391.6984;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-240.9041,299.6321;Inherit;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;31;78.14648,297.435;Inherit;True;SwitchByMirror;-1;;5;db8a2781d3e644f4db8ccf366bd612ed;0;2;3;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;97;534.1737,121.0557;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;13;-163.4892,394.7858;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;785.1488,126.8281;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;!Zer0/CVRNametag;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;2;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;66;0;69;0
WireConnection;66;2;67;0
WireConnection;34;1;66;0
WireConnection;63;0;34;0
WireConnection;63;1;62;0
WireConnection;94;0;93;1
WireConnection;94;1;93;2
WireConnection;95;0;93;3
WireConnection;95;1;93;4
WireConnection;36;0;34;0
WireConnection;36;1;37;0
WireConnection;65;0;34;0
WireConnection;65;1;64;0
WireConnection;35;0;33;0
WireConnection;35;1;36;0
WireConnection;61;0;33;0
WireConnection;61;1;65;0
WireConnection;4;0;3;0
WireConnection;4;1;2;2
WireConnection;84;0;94;0
WireConnection;84;1;95;0
WireConnection;60;0;33;0
WireConnection;60;1;63;0
WireConnection;51;1;61;0
WireConnection;12;1;35;0
WireConnection;50;1;60;0
WireConnection;83;0;84;0
WireConnection;83;1;85;1
WireConnection;83;2;85;2
WireConnection;83;3;85;3
WireConnection;83;5;87;0
WireConnection;25;0;4;0
WireConnection;7;0;4;0
WireConnection;8;0;6;0
WireConnection;8;1;7;0
WireConnection;53;0;12;1
WireConnection;53;1;57;0
WireConnection;88;1;84;0
WireConnection;88;2;91;1
WireConnection;88;3;91;2
WireConnection;9;0;5;0
WireConnection;9;1;25;0
WireConnection;89;1;83;0
WireConnection;54;0;58;0
WireConnection;54;1;50;2
WireConnection;55;0;59;0
WireConnection;55;1;51;3
WireConnection;80;0;53;0
WireConnection;80;1;54;0
WireConnection;80;2;55;0
WireConnection;90;0;89;0
WireConnection;90;1;88;0
WireConnection;98;0;89;4
WireConnection;98;1;88;0
WireConnection;10;0;8;0
WireConnection;10;1;9;0
WireConnection;79;0;12;4
WireConnection;79;1;50;4
WireConnection;79;2;51;4
WireConnection;92;0;89;4
WireConnection;92;1;90;0
WireConnection;96;0;79;0
WireConnection;96;1;98;0
WireConnection;38;0;80;0
WireConnection;38;1;39;0
WireConnection;11;0;10;0
WireConnection;31;3;96;0
WireConnection;31;2;32;0
WireConnection;97;0;38;0
WireConnection;97;1;92;0
WireConnection;13;0;11;0
WireConnection;0;2;97;0
WireConnection;0;9;13;0
WireConnection;0;10;31;0
ASEEND*/
//CHKSM=9B6EC24F9E42EAF30FD3A32854460D3226A13D09