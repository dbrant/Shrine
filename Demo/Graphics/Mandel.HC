
U0 MandelFrame(CDC *dc,
  I64 width, I64 height,
  F64 xCenter, F64 yCenter,
  F64 xExtent, I64 iterations)
{

  // for future smp use:
  I64 startX = 0;
  I64 maxX = startX + width;
  I64 startY = 0;
  I64 maxY = startY + height;



  F64 xmin = xCenter - (xExtent / 2.0);
  F64 xmax = xmin + xExtent;
  F64 aspect = ToF64(width) / ToF64(height);
  F64 ymin = yCenter - (xExtent / aspect / 2.0);
  F64 ymax = ymin + (xExtent / aspect);

  F64 x, y, x0, y0, x2, y2;
  F64 xscale = (xmax - xmin) / ToF64(width);
  F64 yscale = (ymax - ymin) / ToF64(height);
  I64 iteration;
  I64 px, py;

  for (py = startY; py < maxY; py++) {
    y0 = ymin + ToF64(py) * yscale;
    

    for (px = startX; px < maxX; px++) {
      x = 0.0; y = 0.0;
      x2 = 0.0; y2 = 0.0;
      iteration = 0;
      x0 = xmin + ToF64(px) * xscale;

      while ((x2 + y2) < 4.0) {
        y = (2.0 *x * y) + y0;
        x = x2 - y2 + x0;
        x2 = x * x;
        y2 = y * y;
        if (++iteration > iterations) {
          break;
        }
      }
      
     
      if (iteration >= iterations) {
        dc->color = BLACK;
      } else {
        dc->color = iteration & 15;
      }

      GrPlot(dc, px, py);


    }
  }
}

U0 Mandel() {
  SettingsPush;
  AutoComplete;
  WinBorder;
  WinMax;

  CDC *dc = DCAlias;
  DocClear;
  DCFill;

  
  I64 width = 200;
  I64 height = 200;
  F64 xCenter = -0.5;
  F64 yCenter = 0.0;
  F64 xExtent = 3.0;
  I64 iterations = 32;
  

  I64 msg_code, arg1, arg2;
  I64 lastx, lasty;
  F64 aspect;
  Bool moving = FALSE;
  Bool renderFrame = TRUE;

  while(TRUE) {

    if (renderFrame) {
      renderFrame = FALSE;

      MandelFrame(dc, width, height, xCenter, yCenter,
        xExtent, iterations);
    }

    msg_code = GetMsg(&arg1, &arg2,
      1<<MSG_KEY_DOWN + 1<<MSG_MS_L_DOWN
      + 1<<MSG_MS_L_UP + 1<<MSG_MS_MOVE);

    switch(msg_code) {
      case MSG_MS_MOVE:
        if (moving) {
          renderFrame = TRUE;
          xCenter += (xExtent / ToF64(width) * ToF64(lastx - arg1));
          aspect = ToF64(width) / ToF64(height);
          yCenter += (xExtent / aspect / ToF64(height) * (lasty - arg2));
        }
        lastx = arg1;
        lasty = arg2;        
        break;
      case MSG_MS_L_DOWN:
        moving = TRUE;
        break;
      case MSG_MS_L_UP:
        moving = FALSE;
        break;


      case MSG_KEY_DOWN:
        switch(arg1) {
          case 0:
            U8 code = arg2.u8[0];
            if (code == SC_PAGE_UP ||code == SC_PAGE_DOWN) {
              F64 factor = 0.6666666;
              if (code == SC_PAGE_DOWN) {
                factor = 1.5;
              }
              aspect = ToF64(width) / ToF64(height);
              F64 xmin = xCenter - (xExtent / 2.0);
              F64 xmax = xmin + xExtent;
              F64 xpos = xmin + (ToF64(lastx)*xExtent / ToF64(width));
              F64 ymin = yCenter - (xExtent / aspect / 2.0);
              F64 ymax = ymin + (xExtent / aspect);
              F64 ypos = ymin + (ToF64(lasty) * xExtent / aspect / ToF64(height));

              xmin = xpos - (xpos - xmin)*factor;
              xmax = xpos + (xmax - xpos)*factor;
              ymin = ypos - (ypos - ymin)*factor;
              ymax = ypos = (ymax - ypos)*factor;

              xExtent = xmax - xmin;
              xCenter = xmin + xExtent/2.0;
              yCenter = ymin + xExtent/aspect/2.0;
              renderFrame = TRUE;
            }
            else if(code == SC_HOME) {
              iterations++;
              renderFrame = TRUE;
            }
            else if(code == SC_END) {
              iterations--;
              if (iterations < 2)
                iterations = 2;
              renderFrame = TRUE;
            }
            break;
          case CH_ESC:
          case CH_SHIFT_ESC:
            goto m_done;
          default:
            break;
        }
        break;
      default:
        break;
    }
  }

m_done:
  DCFill;
  DCDel(dc);
  SettingsPop;
}

Mandel;
