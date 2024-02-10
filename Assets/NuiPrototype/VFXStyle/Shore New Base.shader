// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ShoreNewBase"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_Shore("Shore", Float) = 0.03
		_WaterCol("WaterCol", Float) = 0
		_Shore2("Shore2", Float) = 0.69
		_ShoreFoamSub("Shore Foam Sub", Float) = 0.06
		_Noise1("Noise1", 2D) = "white" {}
		_Speed("Speed", Float) = 1
		_ShoreMult("ShoreMult", Float) = 1
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
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float4 screenPos;
			float2 uv_texcoord;
		};

		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _WaterCol;
		uniform sampler2D _Noise1;
		uniform float4 _Noise1_ST;
		uniform float _Shore;
		uniform float _Speed;
		uniform float _Shore2;
		uniform float _ShoreFoamSub;
		uniform float _ShoreMult;
		uniform sampler2D _TextureSample0;
		uniform float4 _TextureSample0_ST;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 temp_cast_0 = (1.0).xxxx;
			float4 color97 = IsGammaSpace() ? float4(0,0.2677474,1,0) : float4(0,0.05827265,1,0);
			float4 color96 = IsGammaSpace() ? float4(0,0.7809463,1,0) : float4(0,0.5720345,1,0);
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth93 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth93 = saturate( abs( ( screenDepth93 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _WaterCol ) ) );
			float4 lerpResult95 = lerp( color97 , color96 , ( 1.0 - distanceDepth93 ));
			float2 uv_Noise1 = i.uv_texcoord * _Noise1_ST.xy + _Noise1_ST.zw;
			float screenDepth50 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth50 = abs( ( screenDepth50 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _Shore ) );
			float mulTime77 = _Time.y * _Speed;
			float screenDepth83 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth83 = abs( ( screenDepth83 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _Shore2 ) );
			float4 temp_cast_1 = (( 1.0 - ( distanceDepth83 - _ShoreFoamSub ) )).xxxx;
			float4 clampResult80 = clamp( ( tex2D( _Noise1, uv_Noise1 ) + sin( ( ( 1.0 - distanceDepth50 ) + mulTime77 ) ) ) , float4( 0,0,0,0 ) , temp_cast_1 );
			float2 uv_TextureSample0 = i.uv_texcoord * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
			float4 lerpResult91 = lerp( float4( 0,0,0,0 ) , step( saturate( ( clampResult80 * _ShoreMult ) ) , float4( 0,0,0,0 ) ) , tex2D( _TextureSample0, uv_TextureSample0 ));
			float4 lerpResult98 = lerp( temp_cast_0 , lerpResult95 , lerpResult91);
			o.Emission = lerpResult98.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.OneMinusNode;75;46.64636,119.6368;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;297.6464,209.6368;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;77;-292.3536,264.6368;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-460.3536,280.6368;Inherit;False;Property;_Speed;Speed;7;0;Create;True;0;0;0;False;0;False;1;5.78;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;701.6464,163.6368;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SinOpNode;79;507.6464,207.6368;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;84;671.6464,568.6368;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;86;867.6464,531.6368;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;80;939.6464,261.6368;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;1240.646,256.6368;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;88;988.6464,418.6368;Inherit;False;Property;_ShoreMult;ShoreMult;8;0;Create;True;0;0;0;False;0;False;1;3.34;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;89;1520.646,270.6368;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;90;1781.646,202.6368;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;91;1983.646,90.63684;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;92;1778.65,-104.9551;Inherit;False;Property;_WaterCol;WaterCol;3;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;94;2435.646,-100.3632;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;95;2600.646,-161.3632;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;97;2024.646,-460.3632;Inherit;False;Constant;_DarkWater;DarkWater;9;0;Create;True;0;0;0;False;0;False;0,0.2677474,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;96;2024.646,-301.3632;Inherit;False;Constant;_BrightWater;BrightWater;9;0;Create;True;0;0;0;False;0;False;0,0.7809463,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3428.849,-119.1046;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;ShoreNewBase;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;2;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;2;5;False;;10;False;;0;1;False;;1;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SamplerNode;32;1423.189,38.88742;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;7077eed64f4929641af856cde65e59ea;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;98;3086.895,-113.9466;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;99;2819.515,-63.20541;Inherit;False;Constant;_Float0;Float 0;9;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;50;-313.7063,37.13514;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;83;409.6431,501.2288;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;93;2018.643,-115.7712;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;73;381.3518,0.1714478;Inherit;True;Property;_Noise1;Noise1;6;0;Create;True;0;0;0;False;0;False;-1;None;3ab2d2597e7d64142a58f623b0e2e7dc;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;57;-552.5435,52.26368;Inherit;False;Property;_Shore;Shore;2;0;Create;True;0;0;0;False;0;False;0.03;0.93;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;168.6497,513.0449;Inherit;False;Property;_Shore2;Shore2;4;0;Create;True;0;0;0;False;0;False;0.69;0.51;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;417.7171,647.3716;Inherit;False;Property;_ShoreFoamSub;Shore Foam Sub;5;0;Create;True;0;0;0;False;0;False;0.06;2.3;0;0;0;1;FLOAT;0
WireConnection;75;0;50;0
WireConnection;76;0;75;0
WireConnection;76;1;77;0
WireConnection;77;0;78;0
WireConnection;81;0;73;0
WireConnection;81;1;79;0
WireConnection;79;0;76;0
WireConnection;84;0;83;0
WireConnection;84;1;85;0
WireConnection;86;0;84;0
WireConnection;80;0;81;0
WireConnection;80;2;86;0
WireConnection;87;0;80;0
WireConnection;87;1;88;0
WireConnection;89;0;87;0
WireConnection;90;0;89;0
WireConnection;91;1;90;0
WireConnection;91;2;32;0
WireConnection;94;0;93;0
WireConnection;95;0;97;0
WireConnection;95;1;96;0
WireConnection;95;2;94;0
WireConnection;0;2;98;0
WireConnection;98;0;99;0
WireConnection;98;1;95;0
WireConnection;98;2;91;0
WireConnection;50;0;57;0
WireConnection;83;0;82;0
WireConnection;93;0;92;0
ASEEND*/
//CHKSM=6A435C93BFF35243657D541E40306EC9B6419E91