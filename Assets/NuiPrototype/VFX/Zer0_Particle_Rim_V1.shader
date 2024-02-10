// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "!Zer0/ParticleRim V1"
{
	Properties
	{
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_scrollx("scroll x", Range( -20 , 20)) = 0
		_scrolly("scroll y", Range( -20 , 20)) = 0
		_rimstrength("rim strength", Range( -1 , 20)) = 0
		[HDR]_rimcolor("rim color", Color) = (0,0,0,0)
		_Bloom("Bloom", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		ZWrite Off
		Blend One One , One One
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow nofog nometa 
		struct Input
		{
			float3 viewDir;
			INTERNAL_DATA
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		uniform float _rimstrength;
		uniform float4 _rimcolor;
		uniform sampler2D _TextureSample1;
		uniform float _scrollx;
		uniform float _scrolly;
		uniform float4 _TextureSample1_ST;
		uniform float _Bloom;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float3 normalizeResult10 = normalize( i.viewDir );
			float dotResult14 = dot( float4(0,0,1,0) , float4( normalizeResult10 , 0.0 ) );
			float mulTime6 = _Time.y * 0.1;
			float4 appendResult7 = (float4(_scrollx , _scrolly , 0.0 , 0.0));
			float2 uv_TextureSample1 = i.uv_texcoord * _TextureSample1_ST.xy + _TextureSample1_ST.zw;
			float2 panner11 = ( mulTime6 * appendResult7.xy + uv_TextureSample1);
			o.Emission = ( ( pow( ( 1.0 - saturate( dotResult14 ) ) , _rimstrength ) * _rimcolor * tex2D( _TextureSample1, panner11 ) ) * _Bloom * i.vertexColor.a ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.CommentaryNode;2;-1744.233,12.57696;Inherit;False;2085.615;767.217;;19;24;21;23;22;18;11;20;15;6;8;7;4;5;3;14;12;10;9;32;Rim Light;0,0.7517242,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;9;-1546.194,43.91302;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;10;-1358.189,47.9229;Inherit;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;12;-1315.766,229.1389;Float;False;Constant;_Color0;Color 0;25;0;Create;True;0;0;0;False;0;False;0,0,1,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;14;-1122.223,46.28094;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1738.461,603.647;Float;False;Property;_scrolly;scroll y;3;0;Create;True;0;0;0;False;0;False;0;0.4;-20;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1735.211,534.527;Float;False;Property;_scrollx;scroll x;2;0;Create;True;0;0;0;False;0;False;0;0.4;-20;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1660.471,680.3541;Float;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;7;-1481.948,543.4351;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-1585.379,421.7899;Inherit;False;0;23;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;6;-1520.707,682.2641;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;15;-928.1943,45.96392;Inherit;True;1;0;FLOAT;1.23;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-878.2343,254.9919;Float;False;Property;_rimstrength;rim strength;4;0;Create;True;0;0;0;False;0;False;0;5.9;-1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;11;-1346.388,452.2919;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;18;-772.3103,47.4179;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;21;-561.2966,70.10052;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-322.7744,48.50201;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;469.693,159.2092;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;31;385.462,297.4642;Inherit;False;Property;_Bloom;Bloom;6;0;Create;True;0;0;0;False;0;False;0;5.73;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;804.0465,119.8054;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;!Zer0/ParticleRim V1;False;False;False;False;False;False;False;False;False;True;True;False;False;False;False;False;False;False;False;False;False;Back;2;False;;0;False;;False;0;False;;0;False;;False;5;Custom;0.5;True;False;0;True;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;4;1;False;;1;False;;4;1;False;;1;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SamplerNode;23;-656.5295,425.4319;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;0;False;0;False;-1;None;34025309caa486143a631fb6e59ca8be;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;22;-570.0582,262.3411;Float;False;Property;_rimcolor;rim color;5;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0.2122642,1,0.9907325,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;32;-47.72803,465.739;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
WireConnection;10;0;9;0
WireConnection;14;0;12;0
WireConnection;14;1;10;0
WireConnection;7;0;5;0
WireConnection;7;1;3;0
WireConnection;6;0;4;0
WireConnection;15;0;14;0
WireConnection;11;0;8;0
WireConnection;11;2;7;0
WireConnection;11;1;6;0
WireConnection;18;0;15;0
WireConnection;21;0;18;0
WireConnection;21;1;20;0
WireConnection;24;0;21;0
WireConnection;24;1;22;0
WireConnection;24;2;23;0
WireConnection;30;0;24;0
WireConnection;30;1;31;0
WireConnection;30;2;32;4
WireConnection;0;2;30;0
WireConnection;23;1;11;0
ASEEND*/
//CHKSM=01866C4913EE159DF7A1860E0D2F59C7E9934435