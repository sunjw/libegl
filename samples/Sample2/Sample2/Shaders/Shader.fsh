//
//  Shader.fsh
//  Sample2
//
//  Created by TM Test on 10/29/14.
//  Copyright (c) 2014 TrendMicro. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
