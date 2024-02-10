// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SlashShader"
{
	Properties
	{
		[Header(Shape Prep)]_Front("Front", Vector) = (0.1,0.2,0,0)
		_Tail("Tail", Vector) = (0.2,0.8,0,0)
		_Inner("Inner", Vector) = (0.1,1,0,0)
		_Edge("Edge", Vector) = (0.9,1,0,0)
		[Header(Main)]_MainNoise("MainNoise", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Vector) = (0,0,0,0)
		[HDR]_MainColor("MainColor", Color) = (1,1,1,0)
		[HDR]_EdgeColor("EdgeColor", Color) = (1,1,1,0)
		[Header(Distortion)]_Distortion("Distortion", 2D) = "bump" {}
		_DistortionStrength("DistortionStrength", Float) = 0
		_DistortionSpeed("DistortionSpeed", Vector) = (0,0,0,0)
		_NoiseAmount("NoiseAmount", Float) = 0.8
		_StepTexture("StepTexture", Vector) = (1,0,0,0)
		_DetailStrength("DetailStrength", Float) = 0
		_GlobalOffset("GlobalOffset", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Blend One One
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _EdgeColor;
		uniform float2 _Edge;
		uniform float4 _GlobalOffset;
		uniform float2 _Tail;
		uniform float2 _Front;
		uniform float2 _Inner;
		uniform sampler2D _MainNoise;
		uniform float2 _NoiseSpeed;
		uniform float4 _MainNoise_ST;
		uniform float _DistortionStrength;
		uniform sampler2D _Distortion;
		uniform float2 _DistortionSpeed;
		uniform float4 _Distortion_ST;
		uniform float _NoiseAmount;
		uniform float4 _MainColor;
		uniform float2 _StepTexture;
		uniform float _DetailStrength;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_TexCoord1 = i.uv_texcoord + _GlobalOffset.xy;
			float smoothstepResult26 = smoothstep( _Edge.x , _Edge.y , ( uv_TexCoord1.y + 0.5 ));
			float smoothstepResult16 = smoothstep( _Edge.x , _Edge.y , ( ( 1.0 - uv_TexCoord1.y ) + 0.5 ));
			float smoothstepResult5 = smoothstep( _Tail.x , _Tail.y , uv_TexCoord1.x);
			float smoothstepResult10 = smoothstep( _Front.x , _Front.y , ( 1.0 - uv_TexCoord1.x ));
			float smoothstepResult39 = smoothstep( _Inner.x , _Inner.y , uv_TexCoord1.y);
			float smoothstepResult38 = smoothstep( _Inner.x , _Inner.y , ( 1.0 - uv_TexCoord1.y ));
			float temp_output_11_0 = ( smoothstepResult5 * smoothstepResult10 * ( smoothstepResult39 * smoothstepResult38 * 4.0 ) );
			float4 temp_cast_1 = (( ( smoothstepResult26 * smoothstepResult16 ) * temp_output_11_0 )).xxxx;
			float2 uv_MainNoise = i.uv_texcoord * _MainNoise_ST.xy + _MainNoise_ST.zw;
			float2 panner53 = ( 1.0 * _Time.y * _NoiseSpeed + uv_MainNoise);
			float2 uv_Distortion = i.uv_texcoord * _Distortion_ST.xy + _Distortion_ST.zw;
			float2 panner62 = ( 1.0 * _Time.y * _DistortionSpeed + uv_Distortion);
			float4 temp_output_83_0 = ( ( 1.0 - tex2D( _MainNoise, ( float3( panner53 ,  0.0 ) + ( _DistortionStrength * UnpackNormal( tex2D( _Distortion, panner62 ) ) ) ).xy ) ) * _NoiseAmount );
			float4 temp_cast_4 = (saturate( temp_output_11_0 )).xxxx;
			float4 temp_output_87_0 = saturate( ( temp_cast_4 - temp_output_83_0 ) );
			float4 temp_cast_5 = (_StepTexture.x).xxxx;
			float4 temp_cast_6 = (_StepTexture.y).xxxx;
			float4 smoothstepResult97 = smoothstep( temp_cast_5 , temp_cast_6 , temp_output_87_0);
			o.Emission = ( ( _EdgeColor * saturate( ( temp_cast_1 - temp_output_83_0 ) ) ) + ( ( temp_output_87_0 * _MainColor ) + ( saturate( smoothstepResult97 ) * _DetailStrength ) ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.CommentaryNode;51;-40,469.5;Inherit;False;794;812;Comment;7;38;39;45;49;50;22;23;FadeSide;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;21;-210,-761.5;Inherit;False;818;525.5;Comment;7;16;15;26;33;30;46;47;Edge;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;14;-698.5,188.5;Inherit;False;532;462;Comment;3;10;9;12;Head;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;13;-913.5,-673.5;Inherit;False;594;457;Comment;2;5;7;Tail;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-912.5,-68.5;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;184.5,14.5;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;10;-400.5,293.5;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.2;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;9;-683.5,228.5;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;5;-550.5,-624.5;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;16;131,-450;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;26;115,-655.5;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;381,-534.5;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;30;-174,-306.5;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;1,-350.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-107,-408.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;38;279.375,945.5;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;39;263.375,740;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;45;55.375,926;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;520,865.5;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;356,1168.5;Inherit;False;Constant;_Float0;Float 0;8;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;22;255,519.5;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;18;519,23.5;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;728,-161.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;53;1040,241.5;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;54;785,253.5;Inherit;False;0;52;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;55;858,374.5;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;5;0;Create;True;0;0;0;False;0;False;0,0;-0.99,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;62;1070.667,536.1667;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;64;888.6667,669.1667;Inherit;False;Property;_DistortionSpeed;DistortionSpeed;10;0;Create;True;0;0;0;False;0;False;0,0;0.66,0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;63;815.6667,548.1667;Inherit;False;0;61;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;65;1245,269.5;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;1624,535.5;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;67;1430,475.5;Inherit;False;Property;_DistortionStrength;DistortionStrength;9;0;Create;True;0;0;0;False;0;False;0;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;61;1318,592.5;Inherit;True;Property;_Distortion;Distortion;8;1;[Header];Create;True;1;Distortion;0;0;False;0;False;-1;None;e02a95f4c98d0154fa1f74ceda3f2f04;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;52;1371,209.5;Inherit;True;Property;_MainNoise;MainNoise;4;1;[Header];Create;True;1;Main;0;0;False;0;False;-1;None;f30a59e1d8c71d144959cf677f995330;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;12;-645.5,489.5;Inherit;False;Property;_Front;Front;0;1;[Header];Create;True;1;Shape Prep;0;0;False;0;False;0.1,0.2;0.1,0.22;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;7;-831.5,-607.5;Inherit;False;Property;_Tail;Tail;1;0;Create;True;0;0;0;False;0;False;0.2,0.8;0.18,0.59;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;15;-160,-534;Inherit;False;Property;_Edge;Edge;3;0;Create;True;0;0;0;False;0;False;0.9,1;1.03,0.985;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;23;10,669.5;Inherit;False;Property;_Inner;Inner;2;0;Create;True;0;0;0;False;0;False;0.1,1;0.1,0.65;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;57;1820,-212.5;Inherit;True;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;89;1835,-435.5;Inherit;True;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;90;2066,-435.5;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;87;2056,-221.5;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;2321,-518.5;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;92;2456,-254.5;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;81;1686,281.5;Inherit;False;Property;_NoiseAmount;NoiseAmount;12;0;Create;True;0;0;0;False;0;False;0.8;1.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;1750,119.5;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;95;1596,117.5;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;20;2049,-637.5;Inherit;False;Property;_EdgeColor;EdgeColor;7;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.8291076,3.327548,4.287094,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;25;2004,247.5;Inherit;False;Property;_MainColor;MainColor;6;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0.1556604,0.4172401,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;2308,230.5;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;102;2067,126.5;Inherit;False;Property;_DetailStrength;DetailStrength;14;0;Create;True;0;0;0;False;0;False;0;2.34;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;97;2260,-49.5;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;104;2440,-35.5;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3245,-300;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;SlashShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;2;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;4;1;False;;1;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;11;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;2575,1.5;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;2796,21.5;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;98;2060,-4.5;Inherit;False;Property;_StepTexture;StepTexture;13;0;Create;True;0;0;0;False;0;False;1,0;0.76,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector4Node;106;-1149,-25.5;Inherit;False;Property;_GlobalOffset;GlobalOffset;15;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;1;1;106;0
WireConnection;11;0;5;0
WireConnection;11;1;10;0
WireConnection;11;2;49;0
WireConnection;10;0;9;0
WireConnection;10;1;12;1
WireConnection;10;2;12;2
WireConnection;9;0;1;1
WireConnection;5;0;1;1
WireConnection;5;1;7;1
WireConnection;5;2;7;2
WireConnection;16;0;47;0
WireConnection;16;1;15;1
WireConnection;16;2;15;2
WireConnection;26;0;46;0
WireConnection;26;1;15;1
WireConnection;26;2;15;2
WireConnection;33;0;26;0
WireConnection;33;1;16;0
WireConnection;30;0;1;2
WireConnection;47;0;30;0
WireConnection;46;0;1;2
WireConnection;38;0;45;0
WireConnection;38;1;23;1
WireConnection;38;2;23;2
WireConnection;39;0;1;2
WireConnection;39;1;23;1
WireConnection;39;2;23;2
WireConnection;45;0;1;2
WireConnection;49;0;39;0
WireConnection;49;1;38;0
WireConnection;49;2;50;0
WireConnection;22;0;1;2
WireConnection;22;1;23;1
WireConnection;22;2;23;2
WireConnection;18;0;11;0
WireConnection;19;0;33;0
WireConnection;19;1;11;0
WireConnection;53;0;54;0
WireConnection;53;2;55;0
WireConnection;62;0;63;0
WireConnection;62;2;64;0
WireConnection;65;0;53;0
WireConnection;65;1;66;0
WireConnection;66;0;67;0
WireConnection;66;1;61;0
WireConnection;61;1;62;0
WireConnection;52;1;65;0
WireConnection;57;0;18;0
WireConnection;57;1;83;0
WireConnection;89;0;19;0
WireConnection;89;1;83;0
WireConnection;90;0;89;0
WireConnection;87;0;57;0
WireConnection;93;0;20;0
WireConnection;93;1;90;0
WireConnection;92;0;93;0
WireConnection;92;1;99;0
WireConnection;83;0;95;0
WireConnection;83;1;81;0
WireConnection;95;0;52;0
WireConnection;94;0;87;0
WireConnection;94;1;25;0
WireConnection;97;0;87;0
WireConnection;97;1;98;1
WireConnection;97;2;98;2
WireConnection;104;0;97;0
WireConnection;0;2;92;0
WireConnection;103;0;104;0
WireConnection;103;1;102;0
WireConnection;99;0;94;0
WireConnection;99;1;103;0
ASEEND*/
//CHKSM=34300EC8BFF52D4322B775B8775739EB9A8E81FE