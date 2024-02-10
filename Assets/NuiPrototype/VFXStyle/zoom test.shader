// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/zoom test"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_FlowSpeed("FlowSpeed", Float) = -0.1
		_TextureSample2("Texture Sample 1", 2D) = "bump" {}
		_FlowRotation("FlowRotation", Float) = 0
		_OutwardsTile("OutwardsTile", Float) = 1.1
		_CircularTile("CircularTile", Float) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _TextureSample0;
		uniform float _FlowSpeed;
		uniform float _FlowRotation;
		uniform float _CircularTile;
		uniform float _OutwardsTile;
		uniform sampler2D _TextureSample2;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 appendResult66 = (float2(_FlowSpeed , _FlowRotation));
			float2 uv_TexCoord2 = i.uv_texcoord + float2( -0.5,-0.5 );
			float2 appendResult55 = (float2(( length( uv_TexCoord2 ) * 1.0 ) , ( atan2( uv_TexCoord2.x , uv_TexCoord2.y ) * ( _CircularTile / 6.28318548202515 ) )));
			float2 break77 = appendResult55;
			float2 appendResult79 = (float2(( break77.x * _OutwardsTile ) , break77.y));
			float2 panner47 = ( 1.0 * _Time.y * appendResult66 + appendResult79);
			o.Emission = tex2D( _TextureSample0, ( float3( panner47 ,  0.0 ) + ( UnpackNormal( tex2D( _TextureSample2, panner47 ) ) * 0.18 ) ).xy ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-453.6254,443.9429;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;55;-242.6254,417.9429;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-442.6254,655.9429;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ATan2OpNode;48;-667.6254,597.9429;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TauNode;51;-715.6254,806.9429;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;31;-655.4111,378.5619;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;85;-570.9111,770.2286;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;77;7.088867,405.2286;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;145.0889,407.2286;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;79;304.0889,412.2286;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;37;736.0889,382.2286;Inherit;True;Property;_TextureSample2;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;77a5fceda9a69f34097de5afcbb91b1b;77a5fceda9a69f34097de5afcbb91b1b;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;66;207.0889,661.2286;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FunctionNode;95;-147.9111,-622.7714;Inherit;False;RadialUV;-1;;8;225976f0d9f6a0045b8e43a44402221b;0;6;20;FLOAT2;0,0;False;21;FLOAT2;0,0;False;17;FLOAT2;0,0;False;24;FLOAT2;0,0;False;32;FLOAT2;0,0;False;33;FLOAT;0;False;3;FLOAT2;0;FLOAT2;22;FLOAT2;25
Node;AmplifyShaderEditor.SimpleAddOpNode;20;870.0889,-27.77142;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;23;687.0889,159.2286;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;0;False;0;False;0.18;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;1083.3,40.40001;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;fea5269a37955084eaa00b7f5f052d76;fea5269a37955084eaa00b7f5f052d76;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;889.0889,222.2286;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;47;449.0889,423.2286;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.4,0.15;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-967,408.5;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;-0.5,-0.5;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1463.8,58.30002;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Custom/zoom test;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Spherical;False;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-13.91113,523.2286;Inherit;False;Property;_OutwardsTile;OutwardsTile;4;0;Create;True;0;0;0;False;0;False;1.1;1.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-10.91113,638.2286;Inherit;False;Property;_FlowSpeed;FlowSpeed;1;0;Create;True;0;0;0;False;0;False;-0.1;-0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-9.911133,707.2286;Inherit;False;Property;_FlowRotation;FlowRotation;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-762.9111,737.2286;Inherit;False;Property;_CircularTile;CircularTile;5;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-682.6254,472.9429;Inherit;False;Constant;_Float5;Float 2;0;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
WireConnection;59;0;31;0
WireConnection;59;1;54;0
WireConnection;55;0;59;0
WireConnection;55;1;50;0
WireConnection;50;0;48;0
WireConnection;50;1;85;0
WireConnection;48;0;2;1
WireConnection;48;1;2;2
WireConnection;31;0;2;0
WireConnection;85;0;84;0
WireConnection;85;1;51;0
WireConnection;77;0;55;0
WireConnection;75;0;77;0
WireConnection;75;1;76;0
WireConnection;79;0;75;0
WireConnection;79;1;77;1
WireConnection;37;1;47;0
WireConnection;66;0;65;0
WireConnection;66;1;68;0
WireConnection;20;0;47;0
WireConnection;20;1;22;0
WireConnection;1;1;20;0
WireConnection;22;0;37;0
WireConnection;22;1;23;0
WireConnection;47;0;79;0
WireConnection;47;2;66;0
WireConnection;0;2;1;0
ASEEND*/
//CHKSM=C038A4D3EC53943CC177FC1F74B64A35DA762055