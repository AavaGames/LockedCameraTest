// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ScreenMasterShaderV1"
{
	Properties
	{
		[Header(Basic Controls)]_Rotation("Rotation", Float) = 0
		_Zoom("Zoom", Float) = 0
		_StretchX("Stretch X", Float) = 1
		_StretchY("Stretch Y ", Float) = 1
		_OffsetX("Offset X", Float) = 0
		_OffsetY("Offset Y", Float) = 0
		[Header(Color Correction)]_MulitplyColor("Mulitply Color", Color) = (1,1,1,0)
		_AddColor("Add Color", Color) = (0,0,0,0)
		_Saturation("Saturation", Float) = 1
		_SaturationColor("SaturationColor", Color) = (0.5843138,0.7843138,0.372549,0)
		_Grayscale("Grayscale", Float) = 0
		_Invert("Invert", Float) = 0
		_ToonStep("ToonStep", Float) = 0
		_ToonStepAmount("ToonStepAmount", Float) = 0
		_FinalMultiply("Final Multiply", Float) = 1
		[Header(Emission Booster (shuvi))]_BoosterValue("Booster Value", Float) = 1
		_EmissionBooster("Emission Booster", Range( 0 , 1)) = 0
		[Header(Pixelization)]_Pixelization("Pixelization", Range( 0 , 1)) = 0
		_PixelAmount("PixelAmount", Float) = 200
		[Header(Dither)]_Dither("Dither", Range( 0 , 1)) = 0
		_AutoShakeNoise("AutoShakeNoise", 2D) = "white" {}
		_AutoShakeSpeed("AutoShakeSpeed", Float) = 1
		_AutoShakeStrength("AutoShakeStrength", Range( 1 , 1.3)) = 1
		[Header(Screen Distortion)][NoScaleOffset]_ScreenDistortion("ScreenDistortion", 2D) = "bump" {}
		_DistortionUV("DistortionUV", Vector) = (0.5,0.5,0.5,0.5)
		_DistortionStrength("DistortionStrength", Float) = 0
		_DistortionSpeedY("DistortionSpeedY", Float) = 0
		_DistortionSpeedX("DistortionSpeedX", Float) = 0
		[Header(Radial Blur)]_RadialDirection("RadialDirection", Float) = 0.1
		_RadialEnable("RadialEnable", Float) = 0
		_RadialMaskOffset("RadialMaskOffset", Vector) = (0,0,0,0)
		_RadialMaskSmoothStep("RadialMaskSmoothStep", Vector) = (0,1,0,0)
		[Header(Screen Texture)]_ScreenTexture("ScreenTexture", 2D) = "white" {}
		_ScreenTexUVs("ScreenTexUVs", Vector) = (0,0,1,1)
		_ScreenTextureMultiply("ScreenTextureMultiply", Float) = 1
		_ScreenTexEnable("ScreenTexEnable", Float) = 0
		[Header(ScreenTexFlipbook)]_Row("Row", Float) = 1
		_Col("Col", Float) = 1
		_Speed("Speed", Float) = 0
		[Header(Distance Fade)]_Opacity("Opacity", Range( 0 , 1)) = 1
		_DistanceFadeMin("Distance Fade Min", Float) = 30
		_DistanceFadeMax("Distance Fade Max", Float) = 50
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+1" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Front
		ZWrite Off
		ZTest Always
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		
		GrabPass{ "_GrabScreen0" }
		CGPROGRAM
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Unlit keepalpha noshadow dithercrossfade vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float4 screenPosition;
		};

		uniform sampler2D _ScreenTexture;
		uniform float4 _ScreenTexUVs;
		uniform float _Col;
		uniform float _Row;
		uniform float _Speed;
		uniform float _ScreenTextureMultiply;
		uniform float _ScreenTexEnable;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabScreen0 )
		uniform sampler2D _AutoShakeNoise;
		uniform float _AutoShakeSpeed;
		uniform float _AutoShakeStrength;
		uniform float _Rotation;
		uniform float _Zoom;
		uniform float _StretchX;
		uniform float _StretchY;
		uniform float _OffsetX;
		uniform float _OffsetY;
		uniform float _PixelAmount;
		uniform float _Pixelization;
		uniform sampler2D _ScreenDistortion;
		uniform float _DistortionSpeedY;
		uniform float4 _DistortionUV;
		uniform float _DistortionSpeedX;
		uniform float _DistortionStrength;
		uniform float _RadialDirection;
		uniform float _RadialEnable;
		uniform float2 _RadialMaskSmoothStep;
		uniform float2 _RadialMaskOffset;
		uniform float _Dither;
		uniform float4 _MulitplyColor;
		uniform float4 _AddColor;
		uniform float4 _SaturationColor;
		uniform float _Saturation;
		uniform float _BoosterValue;
		uniform float _EmissionBooster;
		uniform float _Grayscale;
		uniform float _Invert;
		uniform float _ToonStep;
		uniform float _ToonStepAmount;
		uniform float _FinalMultiply;
		uniform float _DistanceFadeMin;
		uniform float _DistanceFadeMax;
		uniform float _Opacity;


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
			float4 _TilingTextureHidden = float4(20,-20,0.025,-0.025);
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 unityObjectToClipPos1319 = UnityObjectToClipPos( ase_vertex3Pos );
			float2 temp_output_1318_0 = ( (unityObjectToClipPos1319).xy / unityObjectToClipPos1319.w );
			float2 break2298 = (temp_output_1318_0*20.0 + 0.0);
			float2 appendResult2303 = (float2(( ( _TilingTextureHidden.x + break2298.x + _ScreenTexUVs.x ) * _TilingTextureHidden.z * _ScreenTexUVs.z ) , ( ( break2298.y + _TilingTextureHidden.y + _ScreenTexUVs.y ) * _TilingTextureHidden.w * _ScreenTexUVs.w )));
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
			float4 lerpResult2317 = lerp( ( tex2D( _ScreenTexture, fbuv2307 ) * _ScreenTextureMultiply ) , float4( 1,1,1,0 ) , _ScreenTexEnable);
			float2 break1324 = temp_output_1318_0;
			float2 appendResult1320 = (float2(break1324.x , break1324.y));
			float2 break2324 = appendResult1320;
			float mulTime2323 = _Time.y * ( _AutoShakeSpeed * 1.2 );
			float2 temp_cast_0 = (mulTime2323).xx;
			float2 uv_TexCoord2326 = i.uv_texcoord * float2( 0,0 ) + temp_cast_0;
			float2 temp_cast_1 = (( uv_TexCoord2326.x + 0.5 )).xx;
			float mulTime2335 = _Time.y * _AutoShakeSpeed;
			float2 temp_cast_2 = (mulTime2335).xx;
			float2 uv_TexCoord2334 = i.uv_texcoord * float2( 0,0 ) + temp_cast_2;
			float2 temp_cast_3 = (uv_TexCoord2334.y).xx;
			float4 appendResult2321 = (float4(( break2324.x + tex2D( _AutoShakeNoise, temp_cast_1 ).r ) , ( break2324.y + UnpackNormal( tex2D( _AutoShakeNoise, temp_cast_3 ) ).g ) , 0.0 , 0.0));
			float4 lerpResult2340 = lerp( appendResult2321 , float4( appendResult1320, 0.0 , 0.0 ) , _AutoShakeStrength);
			float cos1341 = cos( _Rotation );
			float sin1341 = sin( _Rotation );
			float2 rotator1341 = mul( lerpResult2340.xy - float2( 0,0 ) , float2x2( cos1341 , -sin1341 , sin1341 , cos1341 )) + float2( 0,0 );
			float2 temp_cast_6 = (1.0).xx;
			float2 temp_cast_7 = (0.0).xx;
			float2 temp_cast_8 = (( 1.0 + _Zoom )).xx;
			float2 temp_cast_9 = (0.0).xx;
			float2 break2214 = (temp_cast_8 + (rotator1341 - temp_cast_6) * (temp_cast_9 - temp_cast_8) / (temp_cast_7 - temp_cast_6));
			float2 appendResult2220 = (float2(( break2214.x * _StretchX ) , ( break2214.y * _StretchY )));
			float2 break1490 = appendResult2220;
			float2 appendResult1630 = (float2(( break1490.x + _OffsetX ) , ( break1490.y + _OffsetY )));
			float pixelWidth1457 =  1.0f / _PixelAmount;
			float pixelHeight1457 = 1.0f / _PixelAmount;
			half2 pixelateduv1457 = half2((int)(appendResult1630.x / pixelWidth1457) * pixelWidth1457, (int)(appendResult1630.y / pixelHeight1457) * pixelHeight1457);
			float2 lerpResult1461 = lerp( appendResult1630 , pixelateduv1457 , _Pixelization);
			float2 break1602 = lerpResult1461;
			float2 break1637 = lerpResult1461;
			float mulTime1638 = _Time.y * _DistortionSpeedY;
			float mulTime1632 = _Time.y * _DistortionSpeedX;
			float2 appendResult1634 = (float2((( break1637.y + mulTime1638 )*_DistortionUV.y + _DistortionUV.w) , (( break1637.x + mulTime1632 )*_DistortionUV.x + _DistortionUV.z)));
			float3 tex2DNode1613 = UnpackNormal( tex2D( _ScreenDistortion, appendResult1634 ) );
			float2 appendResult1623 = (float2(tex2DNode1613.r , tex2DNode1613.g));
			float2 break1625 = ( appendResult1623 * _DistortionStrength );
			float2 appendResult1629 = (float2(( break1602.x + break1625.x ) , ( break1625.y + break1602.y )));
			float4 appendResult1525 = (float4(appendResult1629 , 1.0 , 1.0));
			float4 computeGrabScreenPos1527 = ComputeGrabScreenPos( appendResult1525 );
			float4 screenColor2351 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,computeGrabScreenPos1527.xy);
			float2 temp_output_2405_0 = ( appendResult1629 + float2( 0,0 ) );
			float2 _Vector1 = float2(0,0);
			float2 temp_cast_11 = (( 1.0 + ( _RadialDirection * 0.1 ) )).xx;
			float4 appendResult8_g157 = (float4((temp_cast_11 + (temp_output_2405_0 - float2( 1,1 )) * (_Vector1 - temp_cast_11) / (_Vector1 - float2( 1,1 ))) , 1.0 , 1.0));
			float4 computeGrabScreenPos10_g157 = ComputeGrabScreenPos( appendResult8_g157 );
			float4 screenColor2353 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,computeGrabScreenPos10_g157.xy);
			float2 temp_cast_13 = (( 1.0 + ( _RadialDirection * 0.2 ) )).xx;
			float4 appendResult8_g153 = (float4((temp_cast_13 + (temp_output_2405_0 - float2( 1,1 )) * (_Vector1 - temp_cast_13) / (_Vector1 - float2( 1,1 ))) , 1.0 , 1.0));
			float4 computeGrabScreenPos10_g153 = ComputeGrabScreenPos( appendResult8_g153 );
			float4 screenColor2395 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,computeGrabScreenPos10_g153.xy);
			float2 temp_cast_15 = (( 1.0 + ( _RadialDirection * 0.3 ) )).xx;
			float4 appendResult8_g154 = (float4((temp_cast_15 + (temp_output_2405_0 - float2( 1,1 )) * (_Vector1 - temp_cast_15) / (_Vector1 - float2( 1,1 ))) , 1.0 , 1.0));
			float4 computeGrabScreenPos10_g154 = ComputeGrabScreenPos( appendResult8_g154 );
			float4 screenColor2402 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,computeGrabScreenPos10_g154.xy);
			float2 temp_cast_17 = (( 1.0 + ( _RadialDirection * 0.4 ) )).xx;
			float4 appendResult8_g155 = (float4((temp_cast_17 + (temp_output_2405_0 - float2( 1,1 )) * (_Vector1 - temp_cast_17) / (_Vector1 - float2( 1,1 ))) , 1.0 , 1.0));
			float4 computeGrabScreenPos10_g155 = ComputeGrabScreenPos( appendResult8_g155 );
			float4 screenColor2403 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,computeGrabScreenPos10_g155.xy);
			float2 temp_cast_19 = (( 1.0 + ( _RadialDirection * 0.5 ) )).xx;
			float4 appendResult8_g158 = (float4((temp_cast_19 + (temp_output_2405_0 - float2( 1,1 )) * (_Vector1 - temp_cast_19) / (_Vector1 - float2( 1,1 ))) , 1.0 , 1.0));
			float4 computeGrabScreenPos10_g158 = ComputeGrabScreenPos( appendResult8_g158 );
			float4 screenColor2404 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,computeGrabScreenPos10_g158.xy);
			float2 temp_cast_21 = (( 1.0 + ( _RadialDirection * 0.6 ) )).xx;
			float4 appendResult8_g159 = (float4((temp_cast_21 + (temp_output_2405_0 - float2( 1,1 )) * (_Vector1 - temp_cast_21) / (_Vector1 - float2( 1,1 ))) , 1.0 , 1.0));
			float4 computeGrabScreenPos10_g159 = ComputeGrabScreenPos( appendResult8_g159 );
			float4 screenColor2455 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,computeGrabScreenPos10_g159.xy);
			float2 temp_cast_23 = (( 1.0 + ( _RadialDirection * 0.7 ) )).xx;
			float4 appendResult8_g160 = (float4((temp_cast_23 + (temp_output_2405_0 - float2( 1,1 )) * (_Vector1 - temp_cast_23) / (_Vector1 - float2( 1,1 ))) , 1.0 , 1.0));
			float4 computeGrabScreenPos10_g160 = ComputeGrabScreenPos( appendResult8_g160 );
			float4 screenColor2456 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,computeGrabScreenPos10_g160.xy);
			float2 temp_cast_25 = (( 1.0 + ( _RadialDirection * 0.8 ) )).xx;
			float4 appendResult8_g161 = (float4((temp_cast_25 + (temp_output_2405_0 - float2( 1,1 )) * (_Vector1 - temp_cast_25) / (_Vector1 - float2( 1,1 ))) , 1.0 , 1.0));
			float4 computeGrabScreenPos10_g161 = ComputeGrabScreenPos( appendResult8_g161 );
			float4 screenColor2457 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,computeGrabScreenPos10_g161.xy);
			float2 temp_cast_27 = (( 1.0 + ( _RadialDirection * 0.9 ) )).xx;
			float4 appendResult8_g162 = (float4((temp_cast_27 + (temp_output_2405_0 - float2( 1,1 )) * (_Vector1 - temp_cast_27) / (_Vector1 - float2( 1,1 ))) , 1.0 , 1.0));
			float4 computeGrabScreenPos10_g162 = ComputeGrabScreenPos( appendResult8_g162 );
			float4 screenColor2458 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,computeGrabScreenPos10_g162.xy);
			float2 temp_cast_29 = (( 1.0 + ( _RadialDirection * 1.0 ) )).xx;
			float4 appendResult8_g163 = (float4((temp_cast_29 + (temp_output_2405_0 - float2( 1,1 )) * (_Vector1 - temp_cast_29) / (_Vector1 - float2( 1,1 ))) , 1.0 , 1.0));
			float4 computeGrabScreenPos10_g163 = ComputeGrabScreenPos( appendResult8_g163 );
			float4 screenColor2463 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabScreen0,computeGrabScreenPos10_g163.xy);
			float smoothstepResult2480 = smoothstep( _RadialMaskSmoothStep.x , _RadialMaskSmoothStep.y , length( ( appendResult1629 + _RadialMaskOffset ) ));
			float4 lerpResult2454 = lerp( screenColor2351 , ( ( screenColor2351 + ( screenColor2353 + screenColor2395 + screenColor2402 + screenColor2403 + screenColor2404 + screenColor2455 + screenColor2456 + screenColor2457 + screenColor2458 + screenColor2463 ) ) / 12.0 ) , ( _RadialEnable * saturate( smoothstepResult2480 ) ));
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen1353 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither1353 = Dither4x4Bayer( fmod(clipScreen1353.x, 4), fmod(clipScreen1353.y, 4) );
			dither1353 = step( dither1353, lerpResult2454.r );
			float4 lerpResult1359 = lerp( lerpResult2454 , ( dither1353 * lerpResult2454 ) , _Dither);
			float4 temp_output_1542_0 = ( ( lerpResult1359 * _MulitplyColor ) + _AddColor );
			float dotResult1546 = dot( temp_output_1542_0 , _SaturationColor );
			float4 temp_cast_32 = (dotResult1546).xxxx;
			float4 lerpResult1549 = lerp( temp_cast_32 , temp_output_1542_0 , _Saturation);
			float3 linearToGamma2237 = LinearToGammaSpace( lerpResult1549.rgb );
			float grayscale2245 = Luminance(linearToGamma2237);
			float4 temp_cast_35 = (( grayscale2245 * _BoosterValue )).xxxx;
			float4 blendOpSrc2242 = lerpResult1549;
			float4 blendOpDest2242 = temp_cast_35;
			float4 lerpResult2248 = lerp( lerpResult1549 , ( saturate( ( blendOpDest2242/ max( 1.0 - blendOpSrc2242, 0.00001 ) ) )) , _EmissionBooster);
			float grayscale2490 = Luminance(lerpResult2248.rgb);
			float4 temp_cast_37 = (grayscale2490).xxxx;
			float4 lerpResult2492 = lerp( lerpResult2248 , temp_cast_37 , _Grayscale);
			float4 lerpResult2497 = lerp( lerpResult2492 , ( 1.0 - lerpResult2492 ) , _Invert);
			float temp_output_7_0_g164 = _ToonStep;
			float4 lerpResult2501 = lerp( lerpResult2497 , ( ( ceil( ( saturate( lerpResult2497.r ) * temp_output_7_0_g164 ) ) / temp_output_7_0_g164 ) * lerpResult2497 ) , _ToonStepAmount);
			o.Emission = ( ( lerpResult2317 * lerpResult2501 ) * _FinalMultiply ).rgb;
			float4 transform1243 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float clampResult1249 = clamp( distance( float4( _WorldSpaceCameraPos , 0.0 ) , (transform1243).xyzw ) , _DistanceFadeMin , _DistanceFadeMax );
			o.Alpha = ( ( 1.0 - (0.0 + (clampResult1249 - _DistanceFadeMin) * (1.0 - 0.0) / (_DistanceFadeMax - _DistanceFadeMin)) ) - ( 1.0 - _Opacity ) );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.CommentaryNode;2500;26409.29,2922.636;Inherit;False;774;358;Comment;4;2501;2502;2503;2505;Ceiling (toon look);1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;2494;25737.29,2920.636;Inherit;False;612;353;Comment;3;2496;2497;2498;Invert;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;2491;24912.29,2879.136;Inherit;False;760;394;Comment;3;2490;2492;2493;BlackNWhite;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1333;11665.23,3057.029;Inherit;False;1152.3;224.7289;;6;1318;1321;1319;1323;1324;1320;Clipspace UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2337;10928.71,3724.333;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;2320;11063.43,3563.009;Inherit;False;1531.484;757.3862;;13;2321;2325;2331;2326;2334;2324;2323;2335;2340;2450;2451;2452;2339;Auto Shake;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;2323;11096.49,3733.737;Inherit;False;1;0;FLOAT;15;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;2324;11095.93,3611.388;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;2325;12269.49,3633.45;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;2331;12273.73,3732.339;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1363;12654.85,3567.152;Inherit;False;453.3613;274.6331;;3;1341;1348;1343;Rotation;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;2321;12411.27,3639.319;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;1489;13154.71,3406.592;Inherit;False;666.9482;631.8062;;7;1487;1536;1473;1478;1477;1534;1535;Zoom;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;1343;12668.39,3617.152;Float;False;Constant;_Vector0;Vector 0;15;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.LerpOp;2340;12427.62,4054.355;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;2215;13886.69,3421.814;Inherit;False;738.0449;359.791;;6;2220;2219;2217;2216;2218;2214;Stretch;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;2219;13995.81,3658.105;Float;False;Property;_StretchY;Stretch Y ;4;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;2214;13905.56,3473.543;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2216;14268.17,3493.41;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2217;14265.84,3616.43;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1496;14741.21,3469.553;Inherit;False;699.0693;409.3241;;6;1494;1490;1493;1491;1492;1630;Offset;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;2220;14443.65,3543.978;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1494;14883.16,3763.877;Float;False;Property;_OffsetY;Offset Y;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;1490;14791.21,3519.553;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;1493;14876.07,3668.942;Float;False;Property;_OffsetX;Offset X;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1491;15099.89,3618.07;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1492;15107.78,3740.233;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1488;15650.88,3536.894;Inherit;False;655.208;306.3633;;4;1462;1457;1461;1463;Pixelization;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;1630;15284.75,3676.916;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;1628;16384.6,3673.696;Inherit;False;2074.041;636.0939;;21;1626;1621;1602;1625;1622;1618;1623;1613;1634;1654;1652;1635;1636;1658;1632;1638;1637;1640;1639;1629;2485;NormalMapDistortion;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;1461;16142.58,3605.104;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1640;16400.79,3975.801;Float;False;Property;_DistortionSpeedY;DistortionSpeedY;27;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;1637;16419.43,3737.673;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleTimeNode;1632;16601.6,3865.42;Inherit;False;1;0;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;1638;16610.59,3979.965;Inherit;False;1;0;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;1658;16766.06,4125.632;Float;False;Property;_DistortionUV;DistortionUV;25;0;Create;True;0;0;0;False;0;False;0.5,0.5,0.5,0.5;0.5,0.5,0.5,0.5;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;1635;16851.17,3848.915;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1636;16852.23,3958.192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1654;17071.06,4143.632;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1.96;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;1652;17045.28,4024.338;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1.96;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1634;17125.39,3888.56;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;1623;17558.08,3817.735;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1618;17415.07,4060.186;Float;False;Property;_DistortionStrength;DistortionStrength;26;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1622;17699.52,3822.263;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;1625;17854.09,3815.279;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;1602;17854.46,3716.326;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.CommentaryNode;1537;19046.26,3651.453;Inherit;False;569.0977;168;;3;1527;1526;1525;normalize;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1621;18146.68,3757.15;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1626;18139.62,3849.448;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;1629;18310.59,3815.921;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;1519;21072.65,2959.027;Inherit;False;743.4902;304.1038;;4;1353;1361;1360;1359;Dither;1,0.5882353,0.5882353,1;0;0
Node;AmplifyShaderEditor.DitheringNode;1353;21122.65,3063.408;Inherit;False;0;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1361;21384.02,3033.985;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;1595;21836.65,2838.857;Inherit;False;434.6006;302.7766;Comment;2;1541;1540;Multiply Color;1,0.6029412,0.6029412,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;2342;12225.84,2262.526;Inherit;False;1036.609;581.6931;;8;2260;2305;2298;2319;2299;2300;2304;2306;texture to screen;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1596;22313.74,2836.195;Inherit;False;424.9199;305.4383;;2;1543;1542;Additive Color;1,0.4705882,0.4705882,1;0;0
Node;AmplifyShaderEditor.LerpOp;1359;21632.14,3009.027;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;1543;22363.74,2886.195;Float;False;Property;_AddColor;Add Color;8;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;2260;12275.84,2320.982;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;20;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;1597;22831.65,2964.877;Inherit;False;779.3477;364.103;;4;1549;1546;1550;1551;Saturation;1,0.5220588,0.5220588,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1540;22102.25,3008.634;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;1551;22881.65,3095.619;Float;False;Property;_SaturationColor;SaturationColor;10;0;Create;True;0;0;0;False;0;False;0.5843138,0.7843138,0.372549,0;0.5843138,0.7843138,0.372549,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;2298;12505.45,2320.526;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;1542;22584.65,3008.633;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;2300;12862.45,2313.526;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;2299;12875.85,2469.424;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1546;23170.22,2996.446;Inherit;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1550;23190.86,3247.989;Float;False;Property;_Saturation;Saturation;9;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1549;23462.15,3010.382;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;2246;23729.79,2858.354;Inherit;False;1073.988;270.7651;By Shuvi;7;2248;2242;2243;2244;2245;2237;2250;Emission Booster;1,0.4852941,0.4852941,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2306;13093.45,2453.526;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;2343;13327.07,2243.691;Inherit;False;578.5;569.1311;Comment;6;2310;2303;2308;2309;2311;2307;screen texture flipbook;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2304;13093.45,2312.526;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;2303;13445.5,2293.691;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LinearToGammaNode;2237;23779.79,2908.354;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;2311;13377.07,2702.823;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2310;13387.46,2609.222;Float;False;Property;_Speed;Speed;39;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1242;24757.35,3705.138;Inherit;False;1641.436;346.9897;;12;1254;1253;1252;1251;1250;1249;1248;1247;1246;1245;1244;1243;Distance Fade;0,0,0,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;2308;13382.28,2441.522;Float;False;Property;_Col;Col;38;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;1243;24833.57,3890.732;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;2344;14048.21,2347.297;Inherit;False;918.5801;435.5449;;5;2251;2313;2318;2312;2317;Texture settings;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCGrayscale;2245;24010.06,2930.151;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;2307;13630.57,2357.021;Inherit;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.WorldSpaceCameraPos;1244;24768.04,3749.913;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2243;24246.27,2990.199;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;1245;25030.96,3843.586;Inherit;False;True;True;True;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2312;14517.43,2426.872;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;2242;24414.91,2897.833;Inherit;False;ColorDodge;True;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1247;25276.56,3957.944;Float;False;Property;_DistanceFadeMax;Distance Fade Max;42;0;Create;True;0;0;0;False;0;False;50;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1246;25273.91,3883.508;Float;False;Property;_DistanceFadeMin;Distance Fade Min;41;0;Create;True;0;0;0;False;0;False;30;30;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;1248;25347.18,3748.081;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;1249;25495.57,3748.42;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;2248;24649.06,2920.913;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;2317;14782.79,2461.038;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,1,1,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;1250;25652.04,3743.487;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1253;25824.76,3742.288;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;1252;26105.65,3821.44;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1254;26268.59,3743.533;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;1341;12877.08,3627.749;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;2250;24385.44,3050.398;Float;False;Property;_EmissionBooster;Emission Booster;17;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1536;13415.6,3783.054;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1473;13652.39,3451.36;Inherit;False;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,0;False;3;FLOAT2;0,0;False;4;FLOAT2;1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1534;13210.5,3870.087;Float;False;Constant;_x2;x2;14;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1487;13231.19,3953.239;Float;False;Property;_Zoom;Zoom;1;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1535;13194.7,3778.207;Float;False;Constant;_y2;y2;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1478;13190.93,3677.325;Float;False;Constant;_y1;y1;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1477;13196.76,3607.956;Float;False;Constant;_x1;x1;13;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComputeGrabScreenPosHlpNode;1527;19406.37,3697.356;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;1526;19081.43,3738.247;Float;False;Constant;_Float9;Float 9;14;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2391;19492.64,4117.896;Inherit;False;Constant;_Float11;Float 11;53;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2394;19492.06,4286.305;Inherit;False;Constant;_Float12;Float 11;53;0;Create;True;0;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2397;19486.25,4424.517;Inherit;False;Constant;_Float13;Float 11;53;0;Create;True;0;0;0;False;0;False;0.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2399;19478.13,4561.567;Inherit;False;Constant;_Float14;Float 11;53;0;Create;True;0;0;0;False;0;False;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;2432;19658.14,4256.105;Inherit;False;RadialLayer;-1;;153;c7afae542811ce142b6f4529d31abec5;0;3;11;FLOAT2;0,0;False;12;FLOAT;0;False;14;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;2433;19652.33,4394.317;Inherit;False;RadialLayer;-1;;154;c7afae542811ce142b6f4529d31abec5;0;3;11;FLOAT2;0,0;False;12;FLOAT;0;False;14;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;2434;19644.21,4532.528;Inherit;False;RadialLayer;-1;;155;c7afae542811ce142b6f4529d31abec5;0;3;11;FLOAT2;0,0;False;12;FLOAT;0;False;14;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;2436;19658.72,4087.696;Inherit;False;RadialLayer;-1;;157;c7afae542811ce142b6f4529d31abec5;0;3;11;FLOAT2;0,0;False;12;FLOAT;0;False;14;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PosVertexDataNode;1323;11672.12,3107.164;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.UnityObjToClipPosHlpNode;1319;11856.6,3107.858;Inherit;False;1;0;FLOAT3;0,0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;1321;12060.94,3105.765;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;1318;12275.14,3101.688;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;1324;12420.59,3125.558;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;1320;12656.14,3131.319;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;2335;11096.93,3848.186;Inherit;False;1;0;FLOAT;14;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;2450;11581.09,3732.888;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2336;10645.13,3797.71;Float;False;Property;_AutoShakeSpeed;AutoShakeSpeed;22;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2339;11952.44,4231.072;Float;False;Property;_AutoShakeStrength;AutoShakeStrength;23;0;Create;True;0;0;0;False;0;False;1;1;1;1.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1348;12671.17,3751.27;Float;False;Property;_Rotation;Rotation;0;1;[Header];Create;True;1;Basic Controls;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2218;14007.67,3565.136;Float;False;Property;_StretchX;Stretch X;3;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2334;11317.03,3845.638;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCPixelate;1457;15866.61,3592.774;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1462;15836.64,3762.503;Float;False;Property;_Pixelization;Pixelization;18;1;[Header];Create;True;1;Pixelization;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1463;15672.57,3720.743;Float;False;Property;_PixelAmount;PixelAmount;19;0;Create;True;0;0;0;False;0;False;200;200;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1639;16397.01,3864.827;Float;False;Property;_DistortionSpeedX;DistortionSpeedX;28;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1251;25832.06,3815.57;Float;False;Property;_Opacity;Opacity;40;1;[Header];Create;True;1;Distance Fade;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1541;21886.65,2888.857;Float;False;Property;_MulitplyColor;Mulitply Color;7;1;[Header];Create;True;1;Color Correction;0;0;False;0;False;1,1,1,0;1,1,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;2244;24038.69,3032.358;Float;False;Property;_BoosterValue;Booster Value;16;1;[Header];Create;True;1;Emission Booster (shuvi);0;0;False;0;False;1;2.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;2305;12337.75,2447.826;Float;False;Constant;_TilingTextureHidden;TilingTextureHidden;34;0;Create;True;0;0;0;False;0;False;20,-20,0.025,-0.025;20,-20,0.025,-0.025;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;2319;12602.48,2633.32;Float;False;Property;_ScreenTexUVs;ScreenTexUVs;34;0;Create;True;0;0;0;False;0;False;0,0,1,1;0,0,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;2309;13386.17,2526.022;Float;False;Property;_Row;Row;37;1;[Header];Create;True;1;ScreenTexFlipbook;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;2456;20164.4,5033.208;Float;False;Global;_GrabScreen7;Grab Screen 0;18;0;Create;True;0;0;0;False;0;False;Instance;2351;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;2435;19631.43,4662.609;Inherit;False;RadialLayer;-1;;158;c7afae542811ce142b6f4529d31abec5;0;3;11;FLOAT2;0,0;False;12;FLOAT;0;False;14;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;2459;19626.2,4853.807;Inherit;False;RadialLayer;-1;;159;c7afae542811ce142b6f4529d31abec5;0;3;11;FLOAT2;0,0;False;12;FLOAT;0;False;14;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;2460;19624.9,5038.408;Inherit;False;RadialLayer;-1;;160;c7afae542811ce142b6f4529d31abec5;0;3;11;FLOAT2;0,0;False;12;FLOAT;0;False;14;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;2461;19621,5258.107;Inherit;False;RadialLayer;-1;;161;c7afae542811ce142b6f4529d31abec5;0;3;11;FLOAT2;0,0;False;12;FLOAT;0;False;14;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;2462;19592.4,5460.907;Inherit;False;RadialLayer;-1;;162;c7afae542811ce142b6f4529d31abec5;0;3;11;FLOAT2;0,0;False;12;FLOAT;0;False;14;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;2464;19592.4,5629.257;Inherit;False;RadialLayer;-1;;163;c7afae542811ce142b6f4529d31abec5;0;3;11;FLOAT2;0,0;False;12;FLOAT;0;False;14;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;2401;19465.35,4692.809;Inherit;False;Constant;_Float15;Float 11;53;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2467;19448.1,4860.307;Inherit;False;Constant;_Float16;Float 11;53;0;Create;True;0;0;0;False;0;False;0.6;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2468;19442.93,5031.919;Inherit;False;Constant;_Float17;Float 11;53;0;Create;True;0;0;0;False;0;False;0.7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2469;19426.93,5222.919;Inherit;False;Constant;_Float18;Float 11;53;0;Create;True;0;0;0;False;0;False;0.8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2470;19409.93,5482.919;Inherit;False;Constant;_Float19;Float 11;53;0;Create;True;0;0;0;False;0;False;0.9;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2471;19419.93,5659.919;Inherit;False;Constant;_Float20;Float 11;53;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;2463;20177.4,5591.558;Float;False;Global;_GrabScreen10;Grab Screen 0;18;0;Create;True;0;0;0;False;0;False;Instance;2351;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;2458;20177.4,5423.208;Float;False;Global;_GrabScreen9;Grab Screen 0;18;0;Create;True;0;0;0;False;0;False;Instance;2351;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;2457;20168.31,5213.906;Float;False;Global;_GrabScreen8;Grab Screen 0;18;0;Create;True;0;0;0;False;0;False;Instance;2351;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;2455;20169.17,4831.707;Float;False;Global;_GrabScreen6;Grab Screen 0;18;0;Create;True;0;0;0;False;0;False;Instance;2351;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;2404;20162.79,4634.736;Float;False;Global;_GrabScreen5;Grab Screen 0;18;0;Create;True;0;0;0;False;0;False;Instance;2351;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;2403;20165.11,4437.29;Float;False;Global;_GrabScreen4;Grab Screen 0;18;0;Create;True;0;0;0;False;0;False;Instance;2351;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;2402;20181.37,4273.528;Float;False;Global;_GrabScreen3;Grab Screen 0;18;0;Create;True;0;0;0;False;0;False;Instance;2351;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;2395;20155.82,4040.079;Float;False;Global;_GrabScreen2;Grab Screen 0;18;0;Create;True;0;0;0;False;0;False;Instance;2351;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;2353;20154.01,3863.442;Float;False;Global;_GrabScreen1;Grab Screen 0;18;0;Create;True;0;0;0;False;0;False;Instance;2351;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;2392;18920.01,4713.375;Inherit;False;Property;_RadialDirection;RadialDirection;29;1;[Header];Create;True;1;Radial Blur;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;2480;19041.81,3982.418;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;2475;18726.81,4052.418;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;2483;18530.81,3957.418;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;2473;20698.44,3841.367;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;2356;20535.25,3604.151;Inherit;False;Constant;_Float10;Float 10;53;0;Create;True;0;0;0;False;0;False;12;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;2485;18260.81,4029.418;Inherit;False;Property;_RadialMaskOffset;RadialMaskOffset;31;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;2354;20512.56,3894.561;Inherit;False;10;10;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;9;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;2355;20764.7,3565.353;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;1525;19257.43,3706.247;Inherit;False;FLOAT4;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;2318;14567.71,2667.842;Float;False;Property;_ScreenTexEnable;ScreenTexEnable;36;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2313;14292,2660.852;Float;False;Property;_ScreenTextureMultiply;ScreenTextureMultiply;35;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2251;14089.91,2401.297;Inherit;True;Property;_ScreenTexture;ScreenTexture;33;1;[Header];Create;True;1;Screen Texture;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2451;11727.09,3735.888;Inherit;True;Property;_AutoShakeNoise;AutoShakeNoise;21;0;Create;True;1;Auto Shake;0;0;False;0;False;-1;2762dfe30c43a5e47873546e74fe90c7;2762dfe30c43a5e47873546e74fe90c7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;2326;11312.12,3722.328;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2452;11561.13,3941.197;Inherit;True;Property;_AutoShakeNoise1;AutoShakeNoise;21;0;Create;True;1;Auto Shake;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;True;Instance;2451;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1613;17266.68,3812.027;Inherit;True;Property;_ScreenDistortion;ScreenDistortion;24;2;[Header];[NoScaleOffset];Create;True;1;Screen Distortion;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;2351;20164.72,3629.7;Float;False;Global;_GrabScreen0;Grab Screen 0;18;0;Create;True;0;0;0;False;0;False;Object;-1;True;False;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;2454;21133.26,3386.868;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1360;21272.06,3163.131;Float;False;Property;_Dither;Dither;20;1;[Header];Create;True;1;Dither;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2488;20969.29,3503.136;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;2489;19403.29,4017.136;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2474;20733.93,3379.744;Inherit;False;Property;_RadialEnable;RadialEnable;30;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;2405;18742.7,4455.419;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;2482;18717.81,4284.418;Inherit;False;Property;_RadialMaskSmoothStep;RadialMaskSmoothStep;32;0;Create;True;0;0;0;False;0;False;0,1;0,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TFHCGrayscale;2490;25109.29,2943.136;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;2492;25387.29,2978.136;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;2493;25138.29,3070.136;Inherit;False;Property;_Grayscale;Grayscale;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;2496;25905.29,3008.636;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;2498;25891.29,3106.636;Inherit;False;Property;_Invert;Invert;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;1170;27458,2676.442;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;ScreenMasterShaderV1;False;False;False;False;False;False;False;False;False;False;False;False;True;False;True;False;False;False;False;False;False;Front;2;False;;7;False;;False;0;False;;0;False;;False;4;Custom;0.5;True;False;1;True;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;2;5;False;;10;False;;2;5;False;;10;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;2;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1592;27162.59,2769.319;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1593;26882.82,2855.765;Float;False;Property;_FinalMultiply;Final Multiply;15;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2316;26869.97,2635.123;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;2497;26156.29,3024.636;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;2504;26405.29,2996.636;Inherit;False;Property;_ToonStep;ToonStep;13;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;2503;26571.29,2969.636;Inherit;False;ToonStep;-1;;164;2d51cd4ae35d8a743bd5c269807f9ea3;0;2;6;FLOAT;0;False;7;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2505;26787.29,2994.636;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;2501;26996.29,3101.636;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;2502;26515.29,3128.636;Inherit;False;Property;_ToonStepAmount;ToonStepAmount;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
WireConnection;2337;0;2336;0
WireConnection;2323;0;2337;0
WireConnection;2324;0;1320;0
WireConnection;2325;0;2324;0
WireConnection;2325;1;2451;1
WireConnection;2331;0;2324;1
WireConnection;2331;1;2452;2
WireConnection;2321;0;2325;0
WireConnection;2321;1;2331;0
WireConnection;2340;0;2321;0
WireConnection;2340;1;1320;0
WireConnection;2340;2;2339;0
WireConnection;2214;0;1473;0
WireConnection;2216;0;2214;0
WireConnection;2216;1;2218;0
WireConnection;2217;0;2214;1
WireConnection;2217;1;2219;0
WireConnection;2220;0;2216;0
WireConnection;2220;1;2217;0
WireConnection;1490;0;2220;0
WireConnection;1491;0;1490;0
WireConnection;1491;1;1493;0
WireConnection;1492;0;1490;1
WireConnection;1492;1;1494;0
WireConnection;1630;0;1491;0
WireConnection;1630;1;1492;0
WireConnection;1461;0;1630;0
WireConnection;1461;1;1457;0
WireConnection;1461;2;1462;0
WireConnection;1637;0;1461;0
WireConnection;1632;0;1639;0
WireConnection;1638;0;1640;0
WireConnection;1635;0;1637;0
WireConnection;1635;1;1632;0
WireConnection;1636;0;1637;1
WireConnection;1636;1;1638;0
WireConnection;1654;0;1636;0
WireConnection;1654;1;1658;2
WireConnection;1654;2;1658;4
WireConnection;1652;0;1635;0
WireConnection;1652;1;1658;1
WireConnection;1652;2;1658;3
WireConnection;1634;0;1654;0
WireConnection;1634;1;1652;0
WireConnection;1623;0;1613;1
WireConnection;1623;1;1613;2
WireConnection;1622;0;1623;0
WireConnection;1622;1;1618;0
WireConnection;1625;0;1622;0
WireConnection;1602;0;1461;0
WireConnection;1621;0;1602;0
WireConnection;1621;1;1625;0
WireConnection;1626;0;1625;1
WireConnection;1626;1;1602;1
WireConnection;1629;0;1621;0
WireConnection;1629;1;1626;0
WireConnection;1353;0;2454;0
WireConnection;1361;0;1353;0
WireConnection;1361;1;2454;0
WireConnection;1359;0;2454;0
WireConnection;1359;1;1361;0
WireConnection;1359;2;1360;0
WireConnection;2260;0;1318;0
WireConnection;1540;0;1359;0
WireConnection;1540;1;1541;0
WireConnection;2298;0;2260;0
WireConnection;1542;0;1540;0
WireConnection;1542;1;1543;0
WireConnection;2300;0;2305;1
WireConnection;2300;1;2298;0
WireConnection;2300;2;2319;1
WireConnection;2299;0;2298;1
WireConnection;2299;1;2305;2
WireConnection;2299;2;2319;2
WireConnection;1546;0;1542;0
WireConnection;1546;1;1551;0
WireConnection;1549;0;1546;0
WireConnection;1549;1;1542;0
WireConnection;1549;2;1550;0
WireConnection;2306;0;2299;0
WireConnection;2306;1;2305;4
WireConnection;2306;2;2319;4
WireConnection;2304;0;2300;0
WireConnection;2304;1;2305;3
WireConnection;2304;2;2319;3
WireConnection;2303;0;2304;0
WireConnection;2303;1;2306;0
WireConnection;2237;0;1549;0
WireConnection;2245;0;2237;0
WireConnection;2307;0;2303;0
WireConnection;2307;1;2308;0
WireConnection;2307;2;2309;0
WireConnection;2307;3;2310;0
WireConnection;2307;5;2311;0
WireConnection;2243;0;2245;0
WireConnection;2243;1;2244;0
WireConnection;1245;0;1243;0
WireConnection;2312;0;2251;0
WireConnection;2312;1;2313;0
WireConnection;2242;0;1549;0
WireConnection;2242;1;2243;0
WireConnection;1248;0;1244;0
WireConnection;1248;1;1245;0
WireConnection;1249;0;1248;0
WireConnection;1249;1;1246;0
WireConnection;1249;2;1247;0
WireConnection;2248;0;1549;0
WireConnection;2248;1;2242;0
WireConnection;2248;2;2250;0
WireConnection;2317;0;2312;0
WireConnection;2317;2;2318;0
WireConnection;1250;0;1249;0
WireConnection;1250;1;1246;0
WireConnection;1250;2;1247;0
WireConnection;1253;0;1250;0
WireConnection;1252;0;1251;0
WireConnection;1254;0;1253;0
WireConnection;1254;1;1252;0
WireConnection;1341;0;2340;0
WireConnection;1341;1;1343;0
WireConnection;1341;2;1348;0
WireConnection;1536;0;1534;0
WireConnection;1536;1;1487;0
WireConnection;1473;0;1341;0
WireConnection;1473;1;1477;0
WireConnection;1473;2;1478;0
WireConnection;1473;3;1536;0
WireConnection;1473;4;1535;0
WireConnection;1527;0;1525;0
WireConnection;2432;11;2405;0
WireConnection;2432;12;2394;0
WireConnection;2432;14;2392;0
WireConnection;2433;11;2405;0
WireConnection;2433;12;2397;0
WireConnection;2433;14;2392;0
WireConnection;2434;11;2405;0
WireConnection;2434;12;2399;0
WireConnection;2434;14;2392;0
WireConnection;2436;11;2405;0
WireConnection;2436;12;2391;0
WireConnection;2436;14;2392;0
WireConnection;1319;0;1323;0
WireConnection;1321;0;1319;0
WireConnection;1318;0;1321;0
WireConnection;1318;1;1319;4
WireConnection;1324;0;1318;0
WireConnection;1320;0;1324;0
WireConnection;1320;1;1324;1
WireConnection;2335;0;2336;0
WireConnection;2450;0;2326;1
WireConnection;2334;1;2335;0
WireConnection;1457;0;1630;0
WireConnection;1457;1;1463;0
WireConnection;1457;2;1463;0
WireConnection;2456;0;2460;0
WireConnection;2435;11;2405;0
WireConnection;2435;12;2401;0
WireConnection;2435;14;2392;0
WireConnection;2459;11;2405;0
WireConnection;2459;12;2467;0
WireConnection;2459;14;2392;0
WireConnection;2460;11;2405;0
WireConnection;2460;12;2468;0
WireConnection;2460;14;2392;0
WireConnection;2461;11;2405;0
WireConnection;2461;12;2469;0
WireConnection;2461;14;2392;0
WireConnection;2462;11;2405;0
WireConnection;2462;12;2470;0
WireConnection;2462;14;2392;0
WireConnection;2464;11;2405;0
WireConnection;2464;12;2471;0
WireConnection;2464;14;2392;0
WireConnection;2463;0;2464;0
WireConnection;2458;0;2462;0
WireConnection;2457;0;2461;0
WireConnection;2455;0;2459;0
WireConnection;2404;0;2435;0
WireConnection;2403;0;2434;0
WireConnection;2402;0;2433;0
WireConnection;2395;0;2432;0
WireConnection;2353;0;2436;0
WireConnection;2480;0;2475;0
WireConnection;2480;1;2482;1
WireConnection;2480;2;2482;2
WireConnection;2475;0;2483;0
WireConnection;2483;0;1629;0
WireConnection;2483;1;2485;0
WireConnection;2473;0;2351;0
WireConnection;2473;1;2354;0
WireConnection;2354;0;2353;0
WireConnection;2354;1;2395;0
WireConnection;2354;2;2402;0
WireConnection;2354;3;2403;0
WireConnection;2354;4;2404;0
WireConnection;2354;5;2455;0
WireConnection;2354;6;2456;0
WireConnection;2354;7;2457;0
WireConnection;2354;8;2458;0
WireConnection;2354;9;2463;0
WireConnection;2355;0;2473;0
WireConnection;2355;1;2356;0
WireConnection;1525;0;1629;0
WireConnection;1525;2;1526;0
WireConnection;1525;3;1526;0
WireConnection;2251;1;2307;0
WireConnection;2451;1;2450;0
WireConnection;2326;1;2323;0
WireConnection;2452;1;2334;2
WireConnection;1613;1;1634;0
WireConnection;2351;0;1527;0
WireConnection;2454;0;2351;0
WireConnection;2454;1;2355;0
WireConnection;2454;2;2488;0
WireConnection;2488;0;2474;0
WireConnection;2488;1;2489;0
WireConnection;2489;0;2480;0
WireConnection;2405;0;1629;0
WireConnection;2490;0;2248;0
WireConnection;2492;0;2248;0
WireConnection;2492;1;2490;0
WireConnection;2492;2;2493;0
WireConnection;2496;0;2492;0
WireConnection;1170;2;1592;0
WireConnection;1170;9;1254;0
WireConnection;1592;0;2316;0
WireConnection;1592;1;1593;0
WireConnection;2316;0;2317;0
WireConnection;2316;1;2501;0
WireConnection;2497;0;2492;0
WireConnection;2497;1;2496;0
WireConnection;2497;2;2498;0
WireConnection;2503;6;2497;0
WireConnection;2503;7;2504;0
WireConnection;2505;0;2503;0
WireConnection;2505;1;2497;0
WireConnection;2501;0;2497;0
WireConnection;2501;1;2505;0
WireConnection;2501;2;2502;0
ASEEND*/
//CHKSM=3F1A88C8B7C172F3FF62905AC8592F671CF75B16