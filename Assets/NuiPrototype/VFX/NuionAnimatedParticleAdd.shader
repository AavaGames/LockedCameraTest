// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "NuionFX/AnimatedParticleAdd"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_DissolveGuide("DissolveGuide", 2D) = "white" {}
		_MainTex("MainTex", 2D) = "white" {}
		_MainTexSpeed("MainTexSpeed", Vector) = (0.1,-0.1,0,0)
		_SecondaryTex("SecondaryTex", 2D) = "white" {}
		_SecondSpeed("SecondSpeed", Vector) = (0.01,-0.01,0,0)
		[HDR]_SecondCol("SecondCol", Color) = (3.031433,3.031433,3.031433,0)
		_DistSecondStrength("DistSecondStrength", Float) = 0.3
		_DistortionMain("DistortionMain", 2D) = "bump" {}
		_DistMainSpeed("DistMainSpeed", Vector) = (0.3,0.1,0,0)
		_DistMainStrength("DistMainStrength", Float) = 1
		_Mask("Mask", 2D) = "white" {}
		_DistortionMask("DistortionMask", 2D) = "bump" {}
		_DistMaskSpeed("DistMaskSpeed", Vector) = (-0.1,0.11,0,0)
		_DistMaskStrength("DistMaskStrength", Float) = 0.5
		_StepHighlight("StepHighlight", Vector) = (0.81,1.24,0,0)
		[HDR]_HighlightCol("HighlightCol", Color) = (2,2,2,0)
		_Bloom("Bloom", Float) = 1
		_Blendness("Blendness", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Blend One One
		
		AlphaToMask On
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float4 vertexColor : COLOR;
			float2 uv_texcoord;
		};

		uniform float _Bloom;
		uniform float4 _SecondCol;
		uniform sampler2D _SecondaryTex;
		uniform float4 _SecondaryTex_ST;
		uniform float2 _SecondSpeed;
		uniform sampler2D _DistortionMain;
		uniform float4 _DistortionMain_ST;
		uniform float2 _DistMainSpeed;
		uniform float _DistSecondStrength;
		uniform sampler2D _MainTex;
		uniform float _DistMainStrength;
		uniform float4 _MainTex_ST;
		uniform float2 _MainTexSpeed;
		uniform sampler2D _Mask;
		uniform float4 _Mask_ST;
		uniform sampler2D _DistortionMask;
		uniform float4 _DistortionMask_ST;
		uniform float2 _DistMaskSpeed;
		uniform float _DistMaskStrength;
		uniform float2 _StepHighlight;
		uniform float4 _HighlightCol;
		uniform float _Blendness;
		uniform sampler2D _DissolveGuide;
		uniform float4 _DissolveGuide_ST;
		uniform float _Cutoff = 0.5;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_SecondaryTex = i.uv_texcoord * _SecondaryTex_ST.xy + _SecondaryTex_ST.zw;
			float2 uv_DistortionMain = i.uv_texcoord * _DistortionMain_ST.xy + _DistortionMain_ST.zw;
			float3 tex2DNode3 = UnpackNormal( tex2D( _DistortionMain, ( uv_DistortionMain + ( _DistMainSpeed * _Time.y ) ) ) );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 uv_Mask = i.uv_texcoord * _Mask_ST.xy + _Mask_ST.zw;
			float2 uv_DistortionMask = i.uv_texcoord * _DistortionMask_ST.xy + _DistortionMask_ST.zw;
			float4 lerpResult30 = lerp( float4( 0,0,0,0 ) , saturate( ( ( _SecondCol * tex2D( _SecondaryTex, ( float3( uv_SecondaryTex ,  0.0 ) + float3( ( _SecondSpeed * _Time.y ) ,  0.0 ) + ( tex2DNode3 * ( _DistSecondStrength / 10.0 ) ) ).xy ) ) + tex2D( _MainTex, ( ( tex2DNode3 * ( _DistMainStrength / 10.0 ) ) + float3( uv_MainTex ,  0.0 ) + float3( ( _MainTexSpeed * _Time.y ) ,  0.0 ) ).xy ) ) ) , tex2D( _Mask, ( float3( uv_Mask ,  0.0 ) + ( UnpackNormal( tex2D( _DistortionMask, ( uv_DistortionMask + ( _DistMaskSpeed * _Time.y ) ) ) ) * ( _DistMaskStrength / 10.0 ) ) ).xy ));
			float4 temp_cast_8 = (_StepHighlight.x).xxxx;
			float4 temp_cast_9 = (_StepHighlight.y).xxxx;
			float4 smoothstepResult39 = smoothstep( temp_cast_8 , temp_cast_9 , lerpResult30);
			float4 temp_output_43_0 = ( lerpResult30 + saturate( ( smoothstepResult39 * _HighlightCol ) ) );
			o.Emission = ( _Bloom * saturate( ( i.vertexColor * temp_output_43_0 ) ) ).rgb;
			float temp_output_9_0_g1 = i.vertexColor.a;
			float4 temp_cast_11 = (temp_output_9_0_g1).xxxx;
			float4 temp_cast_12 = (1.001).xxxx;
			float2 uv_DissolveGuide = i.uv_texcoord * _DissolveGuide_ST.xy + _DissolveGuide_ST.zw;
			float4 smoothstepResult3_g1 = smoothstep( temp_cast_11 , temp_cast_12 , tex2D( _DissolveGuide, uv_DissolveGuide ));
			float4 lerpResult2_g1 = lerp( float4( 1,1,1,0 ) , ( 2.0 * smoothstepResult3_g1 ) , ( temp_output_9_0_g1 * 5.0 ));
			float grayscale4_g1 = Luminance(lerpResult2_g1.xyz);
			float4 temp_cast_15 = (saturate( grayscale4_g1 )).xxxx;
			float4 temp_output_146_0 = ( saturate( ( saturate( temp_output_43_0 ) * _Blendness ) ) - temp_cast_15 );
			o.Alpha = temp_output_146_0.r;
			clip( temp_output_146_0.r - _Cutoff );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.Vector2Node;24;-1901.42,28.54689;Inherit;False;Property;_DistMainSpeed;DistMainSpeed;11;0;Create;True;0;0;0;False;0;False;0.3,0.1;0.3,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;22;-1891.72,149.047;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-1735.11,27.42369;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;20;-1816.92,-93.95319;Inherit;False;0;3;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;23;-1603.42,-34.45298;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-945.3786,-145.3447;Inherit;False;Property;_DistSecondStrength;DistSecondStrength;9;0;Create;True;0;0;0;False;0;False;0.3;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;29;-1957.451,636.8962;Inherit;False;Property;_DistMaskSpeed;DistMaskSpeed;15;0;Create;True;0;0;0;False;0;False;-0.1,0.11;-0.1,0.11;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;26;-1938.399,764.3187;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;53;-735.2919,-162.4423;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-1211.37,17.72548;Inherit;False;Property;_DistMainStrength;DistMainStrength;12;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-1489.588,-62.63895;Inherit;True;Property;_DistortionMain;DistortionMain;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;50;-1197.781,-284.2791;Inherit;False;Property;_SecondSpeed;SecondSpeed;7;0;Create;True;0;0;0;False;0;False;0.01,-0.01;0.01,-0.01;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;51;-1152.699,-162.3047;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;-1774.032,569.9433;Inherit;False;0;14;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-996.0892,-283.928;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;49;-1077.899,-405.3049;Inherit;False;0;47;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1696.123,693.9203;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-611.4969,-226.3828;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;37;-1029.711,9.156031;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;6;-1151.355,174.2741;Inherit;False;Property;_MainTexSpeed;MainTexSpeed;5;0;Create;True;0;0;0;False;0;False;0.1,-0.1;0.1,-0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;7;-1144.338,300.1433;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-864.3994,-345.8047;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1168.158,659.3392;Inherit;False;Property;_DistMaskStrength;DistMaskStrength;16;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;4;-980.1411,111.2211;Inherit;False;0;1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-906.1595,-59.15772;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;-1568.417,614.7214;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-907.854,228.3599;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;47;-611.8058,-459.4651;Inherit;True;Property;_SecondaryTex;SecondaryTex;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;-1445.452,588.626;Inherit;True;Property;_DistortionMask;DistortionMask;14;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;38;-978.2767,659.5547;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;5;-726.6616,125.743;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;60;-522.7742,-624.5876;Inherit;False;Property;_SecondCol;SecondCol;8;1;[HDR];Create;True;0;0;0;False;0;False;3.031433,3.031433,3.031433,0;3.031433,3.031433,3.031433,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-297.2762,-521.3061;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-582.261,89.28967;Inherit;True;Property;_MainTex;MainTex;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-856.2069,591.7565;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-939.2843,469.8151;Inherit;False;0;2;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-727.6906,534.9323;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;-13.93183,-33.18407;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;133;108.7031,-19.90766;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;134;499.2536,183.6631;Inherit;False;696.766;507.5195;Comment;5;39;46;40;44;139;Highlight;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;40;549.2537,298.5078;Inherit;False;Property;_StepHighlight;StepHighlight;17;0;Create;True;0;0;0;False;0;False;0.81,1.24;0.81,1.24;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.LerpOp;30;290.338,-48.65284;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;39;765.2294,250.6979;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;46;733.7236,479.1826;Inherit;False;Property;_HighlightCol;HighlightCol;18;1;[HDR];Create;True;0;0;0;False;0;False;2,2,2,0;2,2,2,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;1007.218,270.515;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;139;1061.447,425.4305;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;1223.216,-0.5855963;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;138;1293.492,479.7238;Inherit;False;878.9418;454.6393;Comment;4;75;125;126;122;Dissolve;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;137;1602.698,186.5681;Inherit;False;524.3823;207.0688;Comment;4;73;74;72;144;Opacity and blend;1,1,1,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;126;1466.157,529.7238;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;144;1664.478,229.446;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;143;1240.681,-206.0762;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;122;1343.492,704.363;Inherit;True;Property;_DissolveGuide;DissolveGuide;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;72;1662.748,316.1637;Inherit;False;Property;_Blendness;Blendness;20;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;125;1693.849,538.3252;Inherit;True;0-1 Dissolve;0;;1;bb12460e46e0a5a45946c64f81a4a83f;0;2;9;FLOAT;0;False;10;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;1824.057,236.5681;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;1423.265,-46.94308;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;135;1555.849,-75.28268;Inherit;False;215;161;Comment;1;61;Normalize;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;136;1799.657,-115.7348;Inherit;False;364.1542;217.4804;Comment;2;63;62;Bloom;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;61;1605.849,-25.28269;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;74;1962.08,257.4077;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;75;2007.434,537.8803;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;1849.657,-65.73479;Inherit;False;Property;_Bloom;Bloom;19;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;2003.486,-55.03049;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;146;2217.256,182.5436;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2385.974,-48.53471;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;NuionFX/AnimatedParticleAdd;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;2;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;4;1;False;;1;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;2;-1;-1;-1;0;True;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SamplerNode;2;-364.3459,336.5249;Inherit;True;Property;_Mask;Mask;13;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;21;0;24;0
WireConnection;21;1;22;0
WireConnection;23;0;20;0
WireConnection;23;1;21;0
WireConnection;53;0;54;0
WireConnection;3;1;23;0
WireConnection;48;0;50;0
WireConnection;48;1;51;0
WireConnection;25;0;29;0
WireConnection;25;1;26;0
WireConnection;55;0;3;0
WireConnection;55;1;53;0
WireConnection;37;0;32;0
WireConnection;52;0;49;0
WireConnection;52;1;48;0
WireConnection;52;2;55;0
WireConnection;31;0;3;0
WireConnection;31;1;37;0
WireConnection;27;0;28;0
WireConnection;27;1;25;0
WireConnection;8;0;6;0
WireConnection;8;1;7;0
WireConnection;47;1;52;0
WireConnection;14;1;27;0
WireConnection;38;0;33;0
WireConnection;5;0;31;0
WireConnection;5;1;4;0
WireConnection;5;2;8;0
WireConnection;59;0;60;0
WireConnection;59;1;47;0
WireConnection;1;1;5;0
WireConnection;34;0;14;0
WireConnection;34;1;38;0
WireConnection;36;0;35;0
WireConnection;36;1;34;0
WireConnection;57;0;59;0
WireConnection;57;1;1;0
WireConnection;133;0;57;0
WireConnection;30;1;133;0
WireConnection;30;2;2;0
WireConnection;39;0;30;0
WireConnection;39;1;40;1
WireConnection;39;2;40;2
WireConnection;44;0;39;0
WireConnection;44;1;46;0
WireConnection;139;0;44;0
WireConnection;43;0;30;0
WireConnection;43;1;139;0
WireConnection;144;0;43;0
WireConnection;125;9;126;4
WireConnection;125;10;122;0
WireConnection;73;0;144;0
WireConnection;73;1;72;0
WireConnection;142;0;143;0
WireConnection;142;1;43;0
WireConnection;61;0;142;0
WireConnection;74;0;73;0
WireConnection;75;0;125;0
WireConnection;62;0;63;0
WireConnection;62;1;61;0
WireConnection;146;0;74;0
WireConnection;146;1;75;0
WireConnection;0;2;62;0
WireConnection;0;9;146;0
WireConnection;0;10;146;0
WireConnection;2;1;36;0
ASEEND*/
//CHKSM=07CF2A756CA665AB5FA05070871BD3967D152D37