// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "!Zer0/InteractiveHolo"
{
	Properties
	{
		_Depth("Depth", Float) = 0
		_Falloff("Falloff", Float) = 0
		_RimColor("Rim Color", Color) = (0,0,0,0)
		_MainTex("MainTex", 2D) = "white" {}
		_ShieldColor("ShieldColor", Color) = (0,0,0,0)
		_ScrollXScrollY("Scroll X - Scroll Y", Vector) = (0,0,0,0)
		_LineSpeed("Line Speed", Float) = 1
		_LineSize("Line Size", Float) = 1.75
		_RimBrightness("RimBrightness", Float) = 1
		_WhiteNoiseBritghtness("WhiteNoiseBritghtness", Float) = 8
		_LineBrightness("Line Brightness", Float) = 8
		_Transparency("Transparency", Float) = 0
		_BiasScalePower("Bias-Scale-Power", Vector) = (0,0,0,0)
		_GlitchStrength("Glitch Strength", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZWrite On
		Blend SrcAlpha OneMinusSrcAlpha , One One
		
		AlphaToMask On
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPos;
			float3 worldPos;
			float3 viewDir;
			INTERNAL_DATA
		};

		uniform float _GlitchStrength;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float2 _ScrollXScrollY;
		uniform float4 _ShieldColor;
		uniform float4 _RimColor;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Depth;
		uniform float _Falloff;
		uniform float _RimBrightness;
		uniform float _LineBrightness;
		uniform float _LineSpeed;
		uniform float _LineSize;
		uniform float _WhiteNoiseBritghtness;
		uniform float4 _BiasScalePower;
		uniform float _Transparency;


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


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			half mulTime154 = _Time.y * 1.3;
			half simplePerlin2D164 = snoise( ( ase_vertex3Pos + mulTime154 ).xy );
			half mulTime167 = _Time.y * 4.85;
			half simplePerlin2D165 = snoise( ( ( ase_vertex3Pos + mulTime167 ) * 1.7 ).xy );
			half mulTime177 = _Time.y * 3.23;
			half simplePerlin2D179 = snoise( ( ( ase_vertex3Pos + mulTime177 ) * 0.78 ).xy );
			half mulTime189 = _Time.y * 3.74;
			half simplePerlin2D187 = snoise( ( ( ase_vertex3Pos + mulTime189 ) * 1.83 ).xy );
			v.vertex.xyz += ( saturate( (( ( saturate( ( saturate( ( simplePerlin2D164 / simplePerlin2D165 ) ) * 0.2 ) ) * saturate( pow( simplePerlin2D179 , 129.4 ) ) * 49.78 ) * simplePerlin2D187 )*_GlitchStrength + 0.0) ) * ase_vertex3Pos );
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float2 uv0_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			half mulTime34 = _Time.y * _ScrollXScrollY.x;
			half mulTime42 = _Time.y * _ScrollXScrollY.y;
			half2 appendResult40 = (half2(( (uv0_MainTex).x + mulTime34 ) , ( (uv0_MainTex).y + mulTime42 )));
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			half eyeDepth13 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_grabScreenPos.xy ));
			half4 temp_output_35_0 = saturate( ( ( tex2D( _MainTex, appendResult40 ) * _ShieldColor ) + float4( 0,0,0,0 ) + saturate( ( saturate( ( _RimColor * ( 1.0 - saturate( pow( ( abs( ( eyeDepth13 - ase_grabScreenPos.a ) ) + _Depth ) , _Falloff ) ) ) ) ) * _RimBrightness ) ) ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			half4 transform50 = mul(unity_ObjectToWorld,half4( ase_vertex3Pos , 0.0 ));
			half mulTime55 = _Time.y * _LineSpeed;
			half2 temp_cast_1 = (( ( transform50.y + mulTime55 ) * _LineSize )).xx;
			half simplePerlin2D53 = snoise( temp_cast_1 );
			half2 temp_cast_2 = (( _LineSize * ( transform50.y + ( 1.0 - mulTime55 ) + 10.96 ) * 0.8 )).xx;
			half simplePerlin2D67 = snoise( temp_cast_2 );
			half4 lerpResult76 = lerp( temp_output_35_0 , ( temp_output_35_0 * _LineBrightness ) , saturate( ( saturate( simplePerlin2D53 ) - saturate( simplePerlin2D67 ) ) ));
			half mulTime108 = _Time.y * 0.31;
			half simplePerlin2D107 = snoise( ( ( i.uv_texcoord + mulTime108 ) * 350.0 ) );
			half mulTime115 = _Time.y * -0.31;
			half simplePerlin2D112 = snoise( ( ( i.uv_texcoord + mulTime115 ) * 400.0 ) );
			half4 lerpResult120 = lerp( saturate( lerpResult76 ) , saturate( ( lerpResult76 * _WhiteNoiseBritghtness ) ) , saturate( ( simplePerlin2D107 / simplePerlin2D112 ) ));
			half fresnelNdotV127 = dot( float4(0,0,1,0).rgb, i.viewDir );
			half fresnelNode127 = ( _BiasScalePower.x + _BiasScalePower.y * pow( 1.0 - fresnelNdotV127, _BiasScalePower.z ) );
			o.Emission = ( saturate( lerpResult120 ) + fresnelNode127 ).rgb;
			o.Alpha = _Transparency;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18100
57;87;1920;1468;-259.4546;349.8697;1.535333;True;True
Node;AmplifyShaderEditor.CommentaryNode;84;-9.125407,-242.1195;Inherit;False;1819.658;549.8147;;12;14;13;15;19;16;17;18;23;24;25;22;20;Intersection;1,1,1,1;0;0
Node;AmplifyShaderEditor.GrabScreenPosition;14;7.271551,-191.6893;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenDepthNode;13;307.8694,-170.9396;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;15;536.8293,-64.26289;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;16;703.514,-54.05993;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;693.7341,42.8013;Float;False;Property;_Depth;Depth;1;0;Create;True;0;0;False;0;False;0;0.91;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;17;849.7469,-35.59678;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;857.1777,89.08586;Float;False;Property;_Falloff;Falloff;2;0;Create;True;0;0;False;0;False;0;1.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;81;171.5667,366.5909;Inherit;False;1643.896;450.6815;Comment;11;43;38;42;39;33;40;34;27;30;31;37;Main Tex;1,1,1,1;0;0
Node;AmplifyShaderEditor.PowerNode;18;1033.245,-43.38436;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;32;344.6161,871.3261;Inherit;False;0;27;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;23;1232.024,-18.10107;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;43;221.5667,576.5549;Float;False;Property;_ScrollXScrollY;Scroll X - Scroll Y;6;0;Create;True;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ComponentMaskNode;37;689.2972,702.2723;Inherit;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;34;729.5845,438.0659;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;80;-959.559,1307.879;Inherit;False;2800.984;630.428;;20;35;78;77;68;60;55;75;73;67;74;66;53;72;70;61;58;71;69;62;76;Line Generator;1,1,1,1;0;0
Node;AmplifyShaderEditor.ComponentMaskNode;38;686.5727,617.8824;Inherit;False;False;True;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;24;1398.715,-22.19588;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;25;1371.654,-192.1195;Float;False;Property;_RimColor;Rim Color;3;0;Create;True;0;0;False;0;False;0,0,0,0;1,1,1,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;42;715.9385,519.0926;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;1641.533,-39.28303;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;926.1092,676.1655;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-909.559,1384.288;Float;False;Property;_LineSpeed;Line Speed;7;0;Create;True;0;0;False;0;False;1;0.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;920.7632,572.4289;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;79;-1499.271,1703.436;Inherit;False;505.3447;252;;2;50;48;World Space;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;55;-718.1252,1357.879;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;40;1115.204,487.6206;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;48;-1449.271,1759.883;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;96;2053.055,39.65663;Float;False;Property;_RimBrightness;RimBrightness;9;0;Create;True;0;0;False;0;False;1;16.54;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;91;2085.853,-70.38022;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;27;1320.355,602.5909;Inherit;True;Property;_MainTex;MainTex;4;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;167;2442.85,2165.413;Inherit;False;1;0;FLOAT;4.85;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;162;2429.356,1784.026;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;2341.215,-47.5452;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-593.4335,1696.278;Float;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;False;0;False;10.96;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;50;-1220.93,1753.436;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;68;-527.4114,1493.634;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;31;1395.858,429.2947;Float;False;Property;_ShieldColor;ShieldColor;5;0;Create;True;0;0;False;0;False;0,0,0,0;0.308391,0.6003163,0.6764706,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;1646.463,470.1247;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;58;-340.5901,1391.731;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;200;2874.697,2222.927;Float;False;Constant;_Float9;Float 9;14;0;Create;True;0;0;False;0;False;1.7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;104;2375.89,147.2109;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-339.3,1775.836;Float;False;Constant;_Float2;Float 2;9;0;Create;True;0;0;False;0;False;0.8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;166;2664.161,2061.742;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;69;-378.6702,1560.677;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-348.3899,1684.221;Float;False;Property;_LineSize;Line Size;8;0;Create;True;0;0;False;0;False;1.75;244.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;154;2434.244,1934.498;Inherit;False;1;0;FLOAT;1.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;199;2923.697,2106.927;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0.2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;1974.474,323.1525;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;163;2654.255,1832.127;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;177;2474.189,2431.816;Inherit;False;1;0;FLOAT;3.23;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-91.81023,1412.175;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-76.90007,1608.937;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;132;-1526.664,2211.117;Inherit;False;1454.238;629.5242;;12;106;115;108;109;111;116;114;113;110;107;112;118;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;164;3057.055,1804.226;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;178;2695.5,2328.145;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;103;1841.717,1184.933;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;165;3079.154,2075.227;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;198;2934.697,2556.927;Float;False;Constant;_Float8;Float 8;14;0;Create;True;0;0;False;0;False;0.78;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;53;144.516,1394.605;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;67;138.1737,1654.676;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;66;335.8188,1404.621;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;173;3297.755,1971.228;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;115;-1328.667,2707.215;Inherit;False;1;0;FLOAT;-0.31;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;108;-1395.91,2446.168;Inherit;False;1;0;FLOAT;0.31;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;74;327.8002,1675.136;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;106;-1476.664,2276.216;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;102;642.085,1243.078;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;197;2960.697,2414.927;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0.2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;176;3465.456,1969.928;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;179;3121.493,2336.63;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-1004.777,2713.641;Float;False;Constant;_Float4;Float 4;12;0;Create;True;0;0;False;0;False;400;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;73;509.1007,1523.136;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;175;3299.056,2131.127;Float;False;Constant;_Float5;Float 5;14;0;Create;True;0;0;False;0;False;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;-1015.425,2418.26;Float;False;Constant;_Float3;Float 3;12;0;Create;True;0;0;False;0;False;350;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;189;2506.71,2726.944;Inherit;False;1;0;FLOAT;3.74;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;109;-1131.425,2332.26;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;35;938.431,1453.625;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;116;-1064.183,2593.306;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;78;845.1136,1694.745;Float;False;Property;_LineBrightness;Line Brightness;11;0;Create;True;0;0;False;0;False;8;2.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-846.4252,2292.26;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;1150.391,1606.57;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;75;725.0714,1525.19;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;174;3627.957,2055.727;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-835.7769,2587.641;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;188;2728.021,2623.273;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;183;3787.205,2343.922;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;129.4;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;193;2859.797,2848.809;Float;False;Constant;_Float6;Float 6;14;0;Create;True;0;0;False;0;False;1.83;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;190;2998.872,2699.309;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0.2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;107;-562.3698,2261.117;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;195;4096.868,2287.404;Float;False;Constant;_Float7;Float 7;14;0;Create;True;0;0;False;0;False;49.78;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;470.6931,2330.304;Float;False;Property;_WhiteNoiseBritghtness;WhiteNoiseBritghtness;10;0;Create;True;0;0;False;0;False;8;1.73;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;184;4074.226,2409.479;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;76;1432.54,1455.903;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;181;3883.125,2085.778;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;112;-551.7216,2556.498;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;775.9705,2242.129;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;187;3191.222,2622.887;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;118;-307.4252,2461.26;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;4286.774,2225.807;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;196;4580.697,2238.927;Float;False;Property;_GlitchStrength;Glitch Strength;14;0;Create;True;0;0;False;0;False;0;0.005;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;123;703.4154,2572.864;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;125;944.8234,2224.463;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;4538.125,2333.779;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;133;1392.827,2317.513;Inherit;False;1048.909;708.3152;;6;130;128;131;126;127;129;Rim;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;124;959.015,2360.963;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;128;1698.864,2398.83;Float;False;Constant;_Color0;Color 0;13;0;Create;True;0;0;False;0;False;0,0,1,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;185;4771.026,2220.979;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;120;1187.107,2330.52;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;131;1677.75,2841.828;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;130;1569.457,2641.223;Float;False;Property;_BiasScalePower;Bias-Scale-Power;13;0;Create;True;0;0;False;0;False;0,0,0,0;0,0.52,4.7,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;83;729.9969,858.6419;Inherit;False;1085.991;310.3539;;4;47;46;44;45;2nd Layer Main Tex;1,1,1,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;150;2739.045,1642.396;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;126;1442.827,2475.166;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;172;4487.255,2020.627;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;127;1913.865,2550.83;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0.62;False;2;FLOAT;1.64;False;3;FLOAT;6.32;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;161;3517.458,1693.026;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;129;2287.738,2367.513;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;105;3294.104,1508.773;Float;False;Property;_Transparency;Transparency;12;0;Create;True;0;0;False;0;False;0;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;45;779.9969,980.6115;Float;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;46;1238.972,908.6419;Inherit;True;Property;_TextureSample0;Texture Sample 0;4;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;27;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;44;935.7533,915.9958;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;1646.988,911.4799;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;1;3671.872,1381.473;Half;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;!Zer0/InteractiveHolo;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;1;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0;True;False;0;True;Custom;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;4;1;False;-1;1;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;True;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;13;0;14;0
WireConnection;15;0;13;0
WireConnection;15;1;14;4
WireConnection;16;0;15;0
WireConnection;17;0;16;0
WireConnection;17;1;19;0
WireConnection;18;0;17;0
WireConnection;18;1;20;0
WireConnection;23;0;18;0
WireConnection;37;0;32;0
WireConnection;34;0;43;1
WireConnection;38;0;32;0
WireConnection;24;0;23;0
WireConnection;42;0;43;2
WireConnection;22;0;25;0
WireConnection;22;1;24;0
WireConnection;33;0;37;0
WireConnection;33;1;34;0
WireConnection;39;0;38;0
WireConnection;39;1;42;0
WireConnection;55;0;60;0
WireConnection;40;0;33;0
WireConnection;40;1;39;0
WireConnection;91;0;22;0
WireConnection;27;1;40;0
WireConnection;101;0;91;0
WireConnection;101;1;96;0
WireConnection;50;0;48;0
WireConnection;68;0;55;0
WireConnection;30;0;27;0
WireConnection;30;1;31;0
WireConnection;58;0;50;2
WireConnection;58;1;55;0
WireConnection;104;0;101;0
WireConnection;166;0;162;0
WireConnection;166;1;167;0
WireConnection;69;0;50;2
WireConnection;69;1;68;0
WireConnection;69;2;71;0
WireConnection;199;0;166;0
WireConnection;199;1;200;0
WireConnection;29;0;30;0
WireConnection;29;2;104;0
WireConnection;163;0;162;0
WireConnection;163;1;154;0
WireConnection;61;0;58;0
WireConnection;61;1;62;0
WireConnection;70;0;62;0
WireConnection;70;1;69;0
WireConnection;70;2;72;0
WireConnection;164;0;163;0
WireConnection;178;0;162;0
WireConnection;178;1;177;0
WireConnection;103;0;29;0
WireConnection;165;0;199;0
WireConnection;53;0;61;0
WireConnection;67;0;70;0
WireConnection;66;0;53;0
WireConnection;173;0;164;0
WireConnection;173;1;165;0
WireConnection;74;0;67;0
WireConnection;102;0;103;0
WireConnection;197;0;178;0
WireConnection;197;1;198;0
WireConnection;176;0;173;0
WireConnection;179;0;197;0
WireConnection;73;0;66;0
WireConnection;73;1;74;0
WireConnection;109;0;106;0
WireConnection;109;1;108;0
WireConnection;35;0;102;0
WireConnection;116;0;106;0
WireConnection;116;1;115;0
WireConnection;110;0;109;0
WireConnection;110;1;111;0
WireConnection;77;0;35;0
WireConnection;77;1;78;0
WireConnection;75;0;73;0
WireConnection;174;0;176;0
WireConnection;174;1;175;0
WireConnection;113;0;116;0
WireConnection;113;1;114;0
WireConnection;188;0;162;0
WireConnection;188;1;189;0
WireConnection;183;0;179;0
WireConnection;190;0;188;0
WireConnection;190;1;193;0
WireConnection;107;0;110;0
WireConnection;184;0;183;0
WireConnection;76;0;35;0
WireConnection;76;1;77;0
WireConnection;76;2;75;0
WireConnection;181;0;174;0
WireConnection;112;0;113;0
WireConnection;121;0;76;0
WireConnection;121;1;122;0
WireConnection;187;0;190;0
WireConnection;118;0;107;0
WireConnection;118;1;112;0
WireConnection;182;0;181;0
WireConnection;182;1;184;0
WireConnection;182;2;195;0
WireConnection;123;0;118;0
WireConnection;125;0;76;0
WireConnection;186;0;182;0
WireConnection;186;1;187;0
WireConnection;124;0;121;0
WireConnection;185;0;186;0
WireConnection;185;1;196;0
WireConnection;120;0;125;0
WireConnection;120;1;124;0
WireConnection;120;2;123;0
WireConnection;126;0;120;0
WireConnection;172;0;185;0
WireConnection;127;0;128;0
WireConnection;127;4;131;0
WireConnection;127;1;130;1
WireConnection;127;2;130;2
WireConnection;127;3;130;3
WireConnection;161;0;172;0
WireConnection;161;1;150;0
WireConnection;129;0;126;0
WireConnection;129;1;127;0
WireConnection;46;1;44;0
WireConnection;44;0;32;0
WireConnection;44;1;45;0
WireConnection;47;0;46;0
WireConnection;47;1;31;0
WireConnection;1;2;129;0
WireConnection;1;9;105;0
WireConnection;1;11;161;0
ASEEND*/
//CHKSM=BDA3C030711639E5DCE0F0E563BE91ADCD64AFB2