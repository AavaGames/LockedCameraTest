// Made by Zer0#9999
// Thanks Shuvi for help
// Thanks Luka for the screen UVs

Shader "!Zer0/DopeScreenV5"
{
	Properties
	{
		[Header(Screen Transforms)]
		_OffsetX("Offset X", Float) = 0
		_OffsetY("Offset Y", Float) = 0
		_StretchX("Stretch X", Float) = 1
		_StretchY("Stretch Y ", Float) = 1
		_Zoom("Zoom", Float) = 0
		_Rotation("Rotation", Float) = 0
		[Header(Dither)]
		_Dither("Dither", Range( 0 , 1)) = 0
		[Header(Pixelation)]
		_Pixels("Pixels", Float) = 200
		_Pixelization("Pixelization", Range( 0 , 1)) = 0
		[Header(Color FX)]
		_AddColor("Add Color", Color) = (0,0,0,0)
		_MulitplyColor("Mulitply Color", Color) = (1,1,1,0)
		_Multiply("Multiply", Float) = 1
		[Header(Saturation)]
		_Saturation("Saturation", Float) = 1
		_SaturationColor("SaturationColor", Color) = (0.5843138,0.7843138,0.372549,0)
		[Header(Sobel)]
		_Intensity("Intensity", Float) = 1
		_SobelColor("Sobel Color", Color) = (0,0,0,0)
		_SobelY("SobelY", Float) = 0
		_SobelX("SobelX", Float) = 0
		[Header(Auto Shake)]
		_AutoShakeSpeed("AutoShakeSpeed", Float) = 1
		_ShakeStrength("ShakeStrength", Range( 1 , 1.3)) = 1
		[Header(Normal Map Distortion)]
		_DistortionUV("DistortionUV", Vector) = (0.5,0.5,0.5,0.5)
		_DistortionTexture("DistortionTexture", 2D) = "bump" {}
		_DistortionStrength("DistortionStrength", Float) = 0
		_DistortionSpeedY("DistortionSpeedY", Float) = 0
		_DistortionSpeedX("DistortionSpeedX", Float) = 0
		[Header(Screen Texture)]
		_Texture("Texture", 2D) = "transparent" {}
		_ScaleTexX("ScaleTexX", Float) = -1
		_ScaleTexY("ScaleTexY", Float) = -1
		_OffsetTexX("OffsetTexX", Float) = 0.5
		_OffsetTexY("OffsetTexY", Float) = 0.5
		_TextureStrength("TextureStrength", Float) = 1
		_cutoff("cutoff", Float) = 0
		[Header(Flipbook Settings)]
		_Speed("Speed", Float) = 0
		_Row("Row", Float) = 1
		_Col("Col", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
		[Header(Distance Fade)]
		_Opacity("Opacity", Range( 0 , 1)) = 1
		_DistanceFadeMin("Distance Fade Min", Float) = 30
		_DistanceFadeMax("Distance Fade Max", Float) = 50
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Overlay+0" "IsEmissive" = "true"  }
		Cull Front
		ZWrite Off
		ZTest Always
		Blend SrcAlpha OneMinusSrcAlpha
		
		GrabPass{ "_GrabPassZero" }
		GrabPass{ "_SobelGrabPass" }
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float4 screenPosition;
		};

		uniform sampler2D _Texture;
		uniform float _ScaleTexX;
		uniform float _ScaleTexY;
		uniform float _OffsetTexX;
		uniform float _OffsetTexY;
		uniform float _Col;
		uniform float _Row;
		uniform float _Speed;
		uniform float _TextureStrength;
		uniform float4 _SobelColor;
		uniform sampler2D _GrabPassZero;
		uniform float _AutoShakeSpeed;
		uniform float _ShakeStrength;
		uniform float _Rotation;
		uniform float _Zoom;
		uniform float _StretchX;
		uniform float _StretchY;
		uniform float _OffsetX;
		uniform float _OffsetY;
		uniform float _Pixels;
		uniform float _Pixelization;
		uniform sampler2D _DistortionTexture;
		uniform float _DistortionSpeedY;
		uniform float4 _DistortionUV;
		uniform float _DistortionSpeedX;
		uniform float _DistortionStrength;
		uniform sampler2D _SobelGrabPass;
		uniform float _SobelX;
		uniform float _SobelY;
		uniform float _Intensity;
		uniform float _Dither;
		uniform float4 _MulitplyColor;
		uniform float4 _AddColor;
		uniform float4 _SaturationColor;
		uniform float _Saturation;
		uniform float _cutoff;
		uniform float _Multiply;
		uniform float _DistanceFadeMin;
		uniform float _DistanceFadeMax;
		uniform float _Opacity;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		inline float Dither4x4Bayer( int x, int y )
		{
			const float dither[ 16 ] = {
				 1,  9,  3, 11,
				13,  5, 15,  7,
				 4, 12,  2, 10,
				16,  8, 14,  6 };
			int r = y * 4 + x;
			return dither[r] / 16; // same # of instructions as pre-dividing due to compiler magic
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 worldToViewDir4_g102 = normalize( mul( UNITY_MATRIX_V, float4( ( ase_worldPos - _WorldSpaceCameraPos ), 0 ) ).xyz );
			float2 break9_g102 = ( (worldToViewDir4_g102).xy / worldToViewDir4_g102.z );
			float4 appendResult11_g102 = (float4(( break9_g102.x * ( _ScreenParams.x / _ScreenParams.y ) ) , break9_g102.y , 0.0 , 0.0));
			float2 appendResult2385 = (float2(_ScaleTexX , _ScaleTexY));
			float2 appendResult2380 = (float2(_OffsetTexX , _OffsetTexY));
			float2 appendResult2303 = (float2((appendResult11_g102*float4( appendResult2385, 0.0 , 0.0 ) + float4( appendResult2380, 0.0 , 0.0 )).xy));
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles2307 = _Col * _Row;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset2307 = 1.0f / _Col;
			float fbrowsoffset2307 = 1.0f / _Row;
			// Speed of animation
			float fbspeed2307 = _Time.y * _Speed;
			// UV Tiling (col and row offset)
			float2 fbtiling2307 = float2(fbcolsoffset2307, fbrowsoffset2307);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex2307 = round( fmod( fbspeed2307 + 0.0, fbtotaltiles2307) );
			fbcurrenttileindex2307 += ( fbcurrenttileindex2307 < 0) ? fbtotaltiles2307 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox2307 = round ( fmod ( fbcurrenttileindex2307, _Col ) );
			// Multiply Offset X by coloffset
			float fboffsetx2307 = fblinearindextox2307 * fbcolsoffset2307;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy2307 = round( fmod( ( fbcurrenttileindex2307 - fblinearindextox2307 ) / _Col, _Row ) );
			// Reverse Y to get tiles from Top to Bottom
			fblinearindextoy2307 = (int)(_Row-1) - fblinearindextoy2307;
			// Multiply Offset Y by rowoffset
			float fboffsety2307 = fblinearindextoy2307 * fbrowsoffset2307;
			// UV Offset
			float2 fboffset2307 = float2(fboffsetx2307, fboffsety2307);
			// Flipbook UV
			half2 fbuv2307 = appendResult2303 * fbtiling2307 + fboffset2307;
			// *** END Flipbook UV Animation vars ***
			float4 tex2DNode2251 = tex2D( _Texture, fbuv2307 );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 unityObjectToClipPos1_g92 = UnityObjectToClipPos( ase_vertex3Pos );
			float2 temp_output_2372_0 = ( (unityObjectToClipPos1_g92).xy / unityObjectToClipPos1_g92.w );
			float2 break2324 = temp_output_2372_0;
			float mulTime2323 = _Time.y * ( _AutoShakeSpeed * 1.2 );
			float2 temp_cast_3 = (mulTime2323).xx;
			float2 uv_TexCoord2326 = i.uv_texcoord * float2( 0,0 ) + temp_cast_3;
			float simplePerlin2D2322 = snoise( uv_TexCoord2326 );
			float mulTime2335 = _Time.y * _AutoShakeSpeed;
			float2 temp_cast_4 = (mulTime2335).xx;
			float2 uv_TexCoord2334 = i.uv_texcoord * float2( 0,0 ) + temp_cast_4;
			float simplePerlin2D2333 = snoise( uv_TexCoord2334 );
			float4 appendResult2321 = (float4(( break2324.x + (simplePerlin2D2322*1.07 + 0.0) ) , ( break2324.y + (simplePerlin2D2333*1.07 + 0.0) ) , 0.0 , 0.0));
			float4 lerpResult2340 = lerp( appendResult2321 , float4( temp_output_2372_0, 0.0 , 0.0 ) , _ShakeStrength);
			float cos1341 = cos( _Rotation );
			float sin1341 = sin( _Rotation );
			float2 rotator1341 = mul( lerpResult2340.xy - float2( 0,0 ) , float2x2( cos1341 , -sin1341 , sin1341 , cos1341 )) + float2( 0,0 );
			float2 temp_cast_7 = (1.0).xx;
			float2 temp_cast_8 = (0.0).xx;
			float2 temp_cast_9 = (( 1.0 + _Zoom )).xx;
			float2 temp_cast_10 = (0.0).xx;
			float2 break2214 = (temp_cast_9 + (rotator1341 - temp_cast_7) * (temp_cast_10 - temp_cast_9) / (temp_cast_8 - temp_cast_7));
			float2 appendResult2220 = (float2(( break2214.x * _StretchX ) , ( break2214.y * _StretchY )));
			float2 break1490 = appendResult2220;
			float2 appendResult1630 = (float2(( break1490.x + _OffsetX ) , ( break1490.y + _OffsetY )));
			float pixelWidth1457 =  1.0f / _Pixels;
			float pixelHeight1457 = 1.0f / _Pixels;
			half2 pixelateduv1457 = half2((int)(appendResult1630.x / pixelWidth1457) * pixelWidth1457, (int)(appendResult1630.y / pixelHeight1457) * pixelHeight1457);
			float2 lerpResult1461 = lerp( appendResult1630 , pixelateduv1457 , _Pixelization);
			float2 break1602 = lerpResult1461;
			float2 break1637 = lerpResult1461;
			float mulTime1638 = _Time.y * _DistortionSpeedY;
			float mulTime1632 = _Time.y * _DistortionSpeedX;
			float2 appendResult1634 = (float2((( break1637.y + mulTime1638 )*_DistortionUV.y + _DistortionUV.w) , (( break1637.x + mulTime1632 )*_DistortionUV.x + _DistortionUV.z)));
			float3 tex2DNode1613 = UnpackNormal( tex2D( _DistortionTexture, appendResult1634 ) );
			float2 appendResult1623 = (float2(tex2DNode1613.r , tex2DNode1613.g));
			float2 break1625 = ( appendResult1623 * _DistortionStrength );
			float2 appendResult1629 = (float2(( break1602.x + break1625.x ) , ( break1625.y + break1602.y )));
			float4 appendResult2353 = (float4(appendResult1629 , 1.0 , 1.0));
			float4 computeGrabScreenPos1527 = ComputeGrabScreenPos( appendResult2353 );
			float4 screenColor2346 = tex2D( _GrabPassZero, computeGrabScreenPos1527.xy );
			float2 localCenter138_g93 = computeGrabScreenPos1527.xy;
			float temp_output_2_0_g93 = _SobelX;
			float localNegStepX156_g93 = -temp_output_2_0_g93;
			float temp_output_3_0_g93 = _SobelY;
			float localStepY164_g93 = temp_output_3_0_g93;
			float2 appendResult14_g95 = (float2(localNegStepX156_g93 , localStepY164_g93));
			float4 screenColor19_g95 = tex2D( _SobelGrabPass, ( localCenter138_g93 + appendResult14_g95 ) );
			float temp_output_2_0_g95 = (screenColor19_g95).r;
			float temp_output_4_0_g95 = (screenColor19_g95).g;
			float temp_output_5_0_g95 = (screenColor19_g95).g;
			float localTopLeft172_g93 = ( sqrt( ( ( ( temp_output_2_0_g95 * temp_output_2_0_g95 ) + ( temp_output_4_0_g95 * temp_output_4_0_g95 ) ) + ( temp_output_5_0_g95 * temp_output_5_0_g95 ) ) ) * _Intensity );
			float2 appendResult14_g100 = (float2(localNegStepX156_g93 , 0.0));
			float4 screenColor19_g100 = tex2D( _SobelGrabPass, ( localCenter138_g93 + appendResult14_g100 ) );
			float temp_output_2_0_g100 = (screenColor19_g100).r;
			float temp_output_4_0_g100 = (screenColor19_g100).g;
			float temp_output_5_0_g100 = (screenColor19_g100).g;
			float localLeft173_g93 = ( sqrt( ( ( ( temp_output_2_0_g100 * temp_output_2_0_g100 ) + ( temp_output_4_0_g100 * temp_output_4_0_g100 ) ) + ( temp_output_5_0_g100 * temp_output_5_0_g100 ) ) ) * _Intensity );
			float localNegStepY165_g93 = -temp_output_3_0_g93;
			float2 appendResult14_g94 = (float2(localNegStepX156_g93 , localNegStepY165_g93));
			float4 screenColor19_g94 = tex2D( _SobelGrabPass, ( localCenter138_g93 + appendResult14_g94 ) );
			float temp_output_2_0_g94 = (screenColor19_g94).r;
			float temp_output_4_0_g94 = (screenColor19_g94).g;
			float temp_output_5_0_g94 = (screenColor19_g94).g;
			float localBottomLeft174_g93 = ( sqrt( ( ( ( temp_output_2_0_g94 * temp_output_2_0_g94 ) + ( temp_output_4_0_g94 * temp_output_4_0_g94 ) ) + ( temp_output_5_0_g94 * temp_output_5_0_g94 ) ) ) * _Intensity );
			float localStepX160_g93 = temp_output_2_0_g93;
			float2 appendResult14_g101 = (float2(localStepX160_g93 , localStepY164_g93));
			float4 screenColor19_g101 = tex2D( _SobelGrabPass, ( localCenter138_g93 + appendResult14_g101 ) );
			float temp_output_2_0_g101 = (screenColor19_g101).r;
			float temp_output_4_0_g101 = (screenColor19_g101).g;
			float temp_output_5_0_g101 = (screenColor19_g101).g;
			float localTopRight177_g93 = ( sqrt( ( ( ( temp_output_2_0_g101 * temp_output_2_0_g101 ) + ( temp_output_4_0_g101 * temp_output_4_0_g101 ) ) + ( temp_output_5_0_g101 * temp_output_5_0_g101 ) ) ) * _Intensity );
			float2 appendResult14_g97 = (float2(localStepX160_g93 , 0.0));
			float4 screenColor19_g97 = tex2D( _SobelGrabPass, ( localCenter138_g93 + appendResult14_g97 ) );
			float temp_output_2_0_g97 = (screenColor19_g97).r;
			float temp_output_4_0_g97 = (screenColor19_g97).g;
			float temp_output_5_0_g97 = (screenColor19_g97).g;
			float localRight178_g93 = ( sqrt( ( ( ( temp_output_2_0_g97 * temp_output_2_0_g97 ) + ( temp_output_4_0_g97 * temp_output_4_0_g97 ) ) + ( temp_output_5_0_g97 * temp_output_5_0_g97 ) ) ) * _Intensity );
			float2 appendResult14_g96 = (float2(localStepX160_g93 , localNegStepY165_g93));
			float4 screenColor19_g96 = tex2D( _SobelGrabPass, ( localCenter138_g93 + appendResult14_g96 ) );
			float temp_output_2_0_g96 = (screenColor19_g96).r;
			float temp_output_4_0_g96 = (screenColor19_g96).g;
			float temp_output_5_0_g96 = (screenColor19_g96).g;
			float localBottomRight179_g93 = ( sqrt( ( ( ( temp_output_2_0_g96 * temp_output_2_0_g96 ) + ( temp_output_4_0_g96 * temp_output_4_0_g96 ) ) + ( temp_output_5_0_g96 * temp_output_5_0_g96 ) ) ) * _Intensity );
			float temp_output_133_0_g93 = ( ( localTopLeft172_g93 + ( localLeft173_g93 * 2 ) + localBottomLeft174_g93 + -localTopRight177_g93 + ( localRight178_g93 * -2 ) + -localBottomRight179_g93 ) / 6.0 );
			float2 appendResult14_g98 = (float2(0.0 , localStepY164_g93));
			float4 screenColor19_g98 = tex2D( _SobelGrabPass, ( localCenter138_g93 + appendResult14_g98 ) );
			float temp_output_2_0_g98 = (screenColor19_g98).r;
			float temp_output_4_0_g98 = (screenColor19_g98).g;
			float temp_output_5_0_g98 = (screenColor19_g98).g;
			float localTop175_g93 = ( sqrt( ( ( ( temp_output_2_0_g98 * temp_output_2_0_g98 ) + ( temp_output_4_0_g98 * temp_output_4_0_g98 ) ) + ( temp_output_5_0_g98 * temp_output_5_0_g98 ) ) ) * _Intensity );
			float2 appendResult14_g99 = (float2(0.0 , localNegStepY165_g93));
			float4 screenColor19_g99 = tex2D( _SobelGrabPass, ( localCenter138_g93 + appendResult14_g99 ) );
			float temp_output_2_0_g99 = (screenColor19_g99).r;
			float temp_output_4_0_g99 = (screenColor19_g99).g;
			float temp_output_5_0_g99 = (screenColor19_g99).g;
			float localBottom176_g93 = ( sqrt( ( ( ( temp_output_2_0_g99 * temp_output_2_0_g99 ) + ( temp_output_4_0_g99 * temp_output_4_0_g99 ) ) + ( temp_output_5_0_g99 * temp_output_5_0_g99 ) ) ) * _Intensity );
			float temp_output_135_0_g93 = ( ( -localTopLeft172_g93 + ( localTop175_g93 * -2 ) + -localTopRight177_g93 + localBottomLeft174_g93 + ( localBottom176_g93 * 2 ) + localBottomRight179_g93 ) / 6.0 );
			float temp_output_111_0_g93 = sqrt( ( ( temp_output_133_0_g93 * temp_output_133_0_g93 ) + ( temp_output_135_0_g93 * temp_output_135_0_g93 ) ) );
			float3 appendResult113_g93 = (float3(temp_output_111_0_g93 , temp_output_111_0_g93 , temp_output_111_0_g93));
			float4 lerpResult2368 = lerp( _SobelColor , screenColor2346 , ( 1.0 - appendResult113_g93 ).x);
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen1353 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither1353 = Dither4x4Bayer( fmod(clipScreen1353.x, 4), fmod(clipScreen1353.y, 4) );
			dither1353 = step( dither1353, lerpResult2368.r );
			float4 lerpResult1359 = lerp( lerpResult2368 , ( dither1353 * lerpResult2368 ) , _Dither);
			float4 temp_output_1542_0 = ( ( lerpResult1359 * _MulitplyColor ) + _AddColor );
			float dotResult1546 = dot( temp_output_1542_0 , _SaturationColor );
			float4 temp_cast_15 = (dotResult1546).xxxx;
			float4 lerpResult1549 = lerp( temp_cast_15 , temp_output_1542_0 , _Saturation);
			float4 lerpResult2317 = lerp( ( tex2DNode2251 * _TextureStrength ) , lerpResult1549 , ( ( 1.0 - tex2DNode2251.a ) * _cutoff ));
			o.Emission = saturate( ( lerpResult2317 * _Multiply ) ).rgb;
			float4 transform1243 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float clampResult1249 = clamp( distance( float4( _WorldSpaceCameraPos , 0.0 ) , (transform1243).xyzw ) , _DistanceFadeMin , _DistanceFadeMax );
			o.Alpha = ( ( 1.0 - (0.0 + (clampResult1249 - _DistanceFadeMin) * (1.0 - 0.0) / (_DistanceFadeMax - _DistanceFadeMin)) ) - ( 1.0 - _Opacity ) );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 customPack2 : TEXCOORD2;
				float3 worldPos : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack2.xyzw = customInputData.screenPosition;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.screenPosition = IN.customPack2.xyzw;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}